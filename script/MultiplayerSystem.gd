extends Node

const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 8

var peer: ENetMultiplayerPeer = null
var is_host: bool = false
var players: Dictionary = {}  # peer_id → player_data
var lobby_code: String = ""

signal player_joined(peer_id: int, data: Dictionary)
signal player_left(peer_id: int)
signal lobby_ready(code: String)
signal game_started
signal connection_failed

func create_lobby() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if err != OK:
		emit_signal("connection_failed")
		return

	multiplayer.multiplayer_peer = peer
	is_host = true

	# Генерируем код лобби из локального IP + порта
	var ip = _get_local_ip()
	lobby_code = _encode_lobby_code(ip, DEFAULT_PORT)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Добавляем себя
	players[1] = _local_player_data()
	emit_signal("lobby_ready", lobby_code)

func join_lobby(code: String) -> void:
	var decoded = _decode_lobby_code(code)
	if decoded.is_empty():
		emit_signal("connection_failed")
		return

	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(decoded["ip"], decoded["port"])
	if err != OK:
		emit_signal("connection_failed")
		return

	multiplayer.multiplayer_peer = peer
	is_host = false

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(func(): emit_signal("connection_failed"))
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_game() -> void:
	if not is_host:
		return
	_rpc_start_game.rpc()

func disconnect_lobby() -> void:
	if peer:
		peer.close()
		peer = null
	players.clear()
	is_host = false
	lobby_code = ""
	multiplayer.multiplayer_peer = null

@rpc("authority", "call_local", "reliable")
func _rpc_start_game() -> void:
	emit_signal("game_started")

@rpc("any_peer", "call_remote", "reliable")
func _rpc_send_player_data(data: Dictionary) -> void:
	var sender = multiplayer.get_remote_sender_id()
	players[sender] = data
	emit_signal("player_joined", sender, data)

func _on_peer_connected(id: int) -> void:
	# Отправляем новому игроку наши данные
	_rpc_send_player_data.rpc_id(id, _local_player_data())

func _on_peer_disconnected(id: int) -> void:
	players.erase(id)
	emit_signal("player_left", id)

func _on_connected_to_server() -> void:
	_rpc_send_player_data.rpc(_local_player_data())

func _local_player_data() -> Dictionary:
	var rank_sys = get_node_or_null("/root/RankSystem")
	return {
		"name": OS.get_unique_id().substr(0, 8),
		"rank": rank_sys.current_rank if rank_sys else 0,
		"rank_name": rank_sys.get_rank_name() if rank_sys else "ЖЕЛЕЗО",
	}

func _get_local_ip() -> String:
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.168.") or addr.begins_with("10."):
			return addr
	return "127.0.0.1"

func _encode_lobby_code(ip: String, port: int) -> String:
	# Простой код: последние два октета IP + порт
	var parts = ip.split(".")
	if parts.size() < 4:
		return "LOCAL"
	return "%s%s-%d" % [parts[2].lpad(3, "0"), parts[3].lpad(3, "0"), port]

func _decode_lobby_code(code: String) -> Dictionary:
	# Формат: XXXYYY-PORT где XXX=октет3, YYY=октет4
	var split = code.split("-")
	if split.size() != 2 or split[0].length() < 6:
		return {}
	var oct3 = split[0].substr(0, 3).to_int()
	var oct4 = split[0].substr(3, 3).to_int()
	var port = split[1].to_int()
	if port == 0:
		port = DEFAULT_PORT
	return {
		"ip": "192.168.%d.%d" % [oct3, oct4],
		"port": port
	}

func get_player_count() -> int:
	return players.size()

func get_players() -> Dictionary:
	return players

func get_lobby_code() -> String:
	return lobby_code
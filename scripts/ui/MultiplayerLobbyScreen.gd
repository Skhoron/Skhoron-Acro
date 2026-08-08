extends Control

@onready var btn_create: Button = $Buttons/BtnCreate
@onready var btn_join: Button = $Buttons/BtnJoin
@onready var btn_start: Button = $Buttons/BtnStart
@onready var btn_back: Button = $Header/BtnBack
@onready var lbl_code: Label = $LobbyInfo/Code
@onready var input_code: LineEdit = $JoinPanel/CodeInput
@onready var player_list: VBoxContainer = $PlayerList
@onready var lbl_status: Label = $Status

var mp: Node

func _ready() -> void:
	mp = get_node_or_null("/root/MultiplayerSystem")
	if mp:
		mp.lobby_ready.connect(_on_lobby_ready)
		mp.player_joined.connect(_on_player_joined)
		mp.player_left.connect(_on_player_left)
		mp.game_started.connect(_on_game_started)
		mp.connection_failed.connect(_on_connection_failed)

	btn_create.pressed.connect(_on_create)
	btn_join.pressed.connect(_on_join)
	btn_start.pressed.connect(_on_start)
	btn_back.pressed.connect(_on_back)
	btn_start.visible = false

func _on_create() -> void:
	if mp:
		lbl_status.text = "Создаю лобби..."
		mp.create_lobby()

func _on_join() -> void:
	if mp and not input_code.text.is_empty():
		lbl_status.text = "Подключаюсь..."
		mp.join_lobby(input_code.text.strip_edges().to_upper())

func _on_start() -> void:
	if mp and mp.is_host:
		mp.start_game()

func _on_lobby_ready(code: String) -> void:
	lbl_code.text = "КОД: %s" % code
	lbl_status.text = "Лобби создано. Ждём игроков..."
	btn_start.visible = true
	_refresh_player_list()

func _on_player_joined(_peer_id: int, _data: Dictionary) -> void:
	lbl_status.text = "Игрок подключился (%d)" % mp.get_player_count()
	_refresh_player_list()

func _on_player_left(_peer_id: int) -> void:
	_refresh_player_list()

func _on_game_started() -> void:
	get_tree().change_scene_to_file("res://scenes/preflight.tscn")

func _on_connection_failed() -> void:
	lbl_status.text = "Ошибка подключения. Проверь код."

func _on_back() -> void:
	if mp:
		mp.disconnect_lobby()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _refresh_player_list() -> void:
	for child in player_list.get_children():
		child.queue_free()
	if not mp:
		return
	for peer_id in mp.get_players():
		var data = mp.get_players()[peer_id]
		var lbl = Label.new()
		lbl.text = "%s — %s" % [data.get("name", "???"), data.get("rank_name", "ЖЕЛЕЗО")]
		player_list.add_child(lbl)
extends Node

# FPV Passport - цифровой профиль пилота
# QR генерируется локально без сервера
# Данные сжимаются в JSON → base64 → QR

var rank_system: Node
var achievement_system: Node
var telemetry: Node

func _ready() -> void:
	rank_system = get_node_or_null("/root/RankSystem")
	achievement_system = get_node_or_null("/root/AchievementSystem")

func generate_passport_data() -> Dictionary:
	var achieved = []
	if achievement_system:
		for i in achievement_system.Achievement.size():
			if achievement_system.is_unlocked(i):
				achieved.append(i)

	return {
		"v": 1,  # версия формата
		"id": OS.get_unique_id().substr(0, 12),
		"rank": rank_system.current_rank if rank_system else 0,
		"xp": rank_system.current_xp if rank_system else 0,
		"achievements": achieved,
		"ts": int(Time.get_unix_time_from_system()),
	}

func generate_qr_string() -> String:
	var data = generate_passport_data()
	var json_str = JSON.stringify(data)
	# Base64 encode
	var encoded = Marshalls.raw_to_base64(json_str.to_utf8_buffer())
	return "SKACRO:" + encoded

func parse_qr_string(qr: String) -> Dictionary:
	if not qr.begins_with("SKACRO:"):
		return {}
	var encoded = qr.substr(7)
	var raw = Marshalls.base64_to_raw(encoded)
	var json_str = raw.get_string_from_utf8()
	var result = JSON.parse_string(json_str)
	if result == null:
		return {}
	return result

func get_passport_summary() -> Dictionary:
	var data = generate_passport_data()
	return {
		"rank_name": rank_system.get_rank_name() if rank_system else "ЖЕЛЕЗО",
		"rank_subtitle": rank_system.get_rank_subtitle() if rank_system else "",
		"xp": data["xp"],
		"achievements_count": data["achievements"].size(),
		"qr_string": generate_qr_string(),
	}
extends Control

@onready var btn_retry: Button = $Buttons/BtnRetry
@onready var btn_menu: Button = $Buttons/BtnMenu
@onready var lbl_medal: Label = $MedalEarned/Label
@onready var lbl_best_time: Label = $Stats/BestTime
@onready var lbl_rank_pos: Label = $Stats/Rank
@onready var lbl_max_alt: Label = $Summary/MaxAlt
@onready var lbl_max_speed: Label = $Summary/MaxSpeed
@onready var lbl_max_throttle: Label = $Summary/MaxThrottle
@onready var lbl_flight_time: Label = $Summary/FlightTime
@onready var lbl_crashes: Label = $Summary/Crashes

var summary: Dictionary = {}

func _ready() -> void:
	btn_retry.pressed.connect(_on_retry)
	btn_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	_load_summary()

func _load_summary() -> void:
	# Summary передаётся через autoload или singleton
	var telemetry = get_node_or_null("/root/TelemetrySystem")
	if telemetry:
		summary = telemetry.get_summary()
		_populate_ui()

func _populate_ui() -> void:
	if summary.is_empty():
		return

	var ft = summary["flight_time"]
	var mins = int(ft / 60)
	var secs = int(fmod(ft, 60))
	lbl_flight_time.text = "%02d:%02d" % [mins, secs]
	lbl_max_alt.text = "%.1f m" % summary["max_altitude"]
	lbl_max_speed.text = "%.1f km/h" % summary["max_speed"]
	lbl_max_throttle.text = "%d %%" % int(summary["max_throttle"])
	lbl_crashes.text = str(summary["crashes"])

func set_medal(medal: int) -> void:
	var names = ["", "БРОНЗА", "СЕРЕБРО", "ЗОЛОТО", "ПЛАТИНА"]
	lbl_medal.text = names[clamp(medal, 0, 4)]

func set_best_time(time_sec: float) -> void:
	var mins = int(time_sec / 60)
	var secs = fmod(time_sec, 60)
	lbl_best_time.text = "%02d:%05.2f" % [mins, secs]

func set_rank_position(pos: int, total: int) -> void:
	lbl_rank_pos.text = "#%d / %d" % [pos, total]

func _on_retry() -> void:
	# Перезапускаем текущую карту
	var map_mgr = get_node_or_null("/root/MapManager")
	if map_mgr:
		var active = map_mgr.get_active()
		if not active.is_empty():
			map_mgr.load_map(active["id"])
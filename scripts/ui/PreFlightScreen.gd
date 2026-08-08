extends Control

@onready var btn_start: Button = $Header/BtnStart
@onready var btn_back: Button = $Header/BtnBack

# PID слайдеры
@onready var slider_roll_p: HSlider = $PID/Roll/P
@onready var slider_roll_i: HSlider = $PID/Roll/I
@onready var slider_roll_d: HSlider = $PID/Roll/D
@onready var slider_pitch_p: HSlider = $PID/Pitch/P
@onready var slider_pitch_i: HSlider = $PID/Pitch/I
@onready var slider_pitch_d: HSlider = $PID/Pitch/D
@onready var slider_yaw_p: HSlider = $PID/Yaw/P
@onready var slider_yaw_i: HSlider = $PID/Yaw/I
@onready var slider_yaw_d: HSlider = $PID/Yaw/D

# Камера
@onready var slider_cam_angle: HSlider = $Camera/AngleSlider
@onready var slider_fov: HSlider = $Camera/FOVSlider
@onready var lbl_angle: Label = $Camera/AngleLabel
@onready var lbl_fov: Label = $Camera/FOVLabel

# Controller input индикаторы
@onready var bar_thr: ProgressBar = $Controller/THR
@onready var bar_roll: ProgressBar = $Controller/ROLL
@onready var bar_pitch: ProgressBar = $Controller/PITCH
@onready var bar_yaw: ProgressBar = $Controller/YAW

# Инфо о дроне
@onready var lbl_drone_info: Label = $Footer/DroneInfo

var map_id: String = ""
var drone_id: String = "racer_x1"

func _ready() -> void:
	_load_session()
	_setup_pid_defaults()
	btn_start.pressed.connect(_on_start)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/map_select.tscn"))
	slider_cam_angle.value_changed.connect(func(v): lbl_angle.text = "%d°" % int(v))
	slider_fov.value_changed.connect(func(v): lbl_fov.text = "%d°" % int(v))

func _process(_delta: float) -> void:
	_update_controller_bars()

func _setup_pid_defaults() -> void:
	slider_roll_p.value = 1.20
	slider_roll_i.value = 0.45
	slider_roll_d.value = 18.0
	slider_pitch_p.value = 1.20
	slider_pitch_i.value = 0.45
	slider_pitch_d.value = 18.0
	slider_yaw_p.value = 1.80
	slider_yaw_i.value = 0.0
	slider_yaw_d.value = 0.0
	slider_cam_angle.value = 35.0
	slider_fov.value = 110.0
	lbl_angle.text = "35°"
	lbl_fov.text = "110°"

func _update_controller_bars() -> void:
	bar_thr.value = (Input.get_joy_axis(0, 1) + 1.0) / 2.0 * 100.0
	bar_roll.value = (Input.get_joy_axis(0, 0) + 1.0) / 2.0 * 100.0
	bar_pitch.value = (Input.get_joy_axis(0, 3) + 1.0) / 2.0 * 100.0
	bar_yaw.value = (Input.get_joy_axis(0, 2) + 1.0) / 2.0 * 100.0

func _load_session() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://session.cfg") == OK:
		map_id = cfg.get_value("session", "map_id", "green_hills")
		drone_id = cfg.get_value("session", "drone_id", "racer_x1")

func _on_start() -> void:
	_save_pid()
	var map_mgr = get_node_or_null("/root/MapManager")
	if map_mgr:
		map_mgr.load_map(map_id)

func _save_pid() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("pid", "roll_p", slider_roll_p.value)
	cfg.set_value("pid", "roll_i", slider_roll_i.value)
	cfg.set_value("pid", "roll_d", slider_roll_d.value)
	cfg.set_value("pid", "pitch_p", slider_pitch_p.value)
	cfg.set_value("pid", "pitch_i", slider_pitch_i.value)
	cfg.set_value("pid", "pitch_d", slider_pitch_d.value)
	cfg.set_value("pid", "yaw_p", slider_yaw_p.value)
	cfg.set_value("pid", "cam_angle", slider_cam_angle.value)
	cfg.set_value("pid", "fov", slider_fov.value)
	cfg.save("user://pid.cfg")
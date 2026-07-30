extends Node

# Supports: USB RC controller (RadioMaster, etc), touch virtual sticks, keyboard

enum InputMode { RC_CONTROLLER, TOUCH, KEYBOARD }
var mode: InputMode = InputMode.TOUCH

# Raw stick values [-1, 1]
var throttle: float = -1.0  # Acro: starts at min throttle
var roll: float = 0.0
var pitch: float = 0.0
var yaw: float = 0.0

# RC channel mapping (customizable)
var ch_throttle: int = 2
var ch_roll: int = 0
var ch_pitch: int = 1
var ch_yaw: int = 3

# Deadband
var deadband: float = 0.05

# Rates (deg/s at full stick)
var roll_rate: float = 700.0
var pitch_rate: float = 700.0
var yaw_rate: float = 400.0

# Touch virtual sticks (set by UI)
var touch_left: Vector2 = Vector2.ZERO   # yaw + throttle
var touch_right: Vector2 = Vector2.ZERO  # roll + pitch

var joystick_connected: bool = false

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_check_joystick()

func _process(_delta: float) -> void:
	match mode:
		InputMode.RC_CONTROLLER:
			_read_rc()
		InputMode.TOUCH:
			_read_touch()
		InputMode.KEYBOARD:
			_read_keyboard()

func _read_rc() -> void:
	if not joystick_connected:
		return
	throttle = _apply_deadband(Input.get_joy_axis(0, ch_throttle))
	roll = _apply_deadband(Input.get_joy_axis(0, ch_roll))
	pitch = _apply_deadband(Input.get_joy_axis(0, ch_pitch))
	yaw = _apply_deadband(Input.get_joy_axis(0, ch_yaw))

func _read_touch() -> void:
	yaw = _apply_deadband(touch_left.x)
	throttle = _apply_deadband(touch_left.y)
	roll = _apply_deadband(touch_right.x)
	pitch = _apply_deadband(touch_right.y)

func _read_keyboard() -> void:
	throttle = float(Input.is_action_pressed("ui_up")) - float(Input.is_action_pressed("ui_down"))
	roll = float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left"))
	pitch = 0.0
	yaw = 0.0

func _apply_deadband(val: float) -> float:
	if absf(val) < deadband:
		return 0.0
	return signf(val) * (absf(val) - deadband) / (1.0 - deadband)

func get_throttle() -> float: return throttle
func get_roll() -> float: return roll * (roll_rate / 700.0)
func get_pitch() -> float: return pitch * (pitch_rate / 700.0)
func get_yaw() -> float: return yaw * (yaw_rate / 400.0)

func set_touch_left(v: Vector2) -> void: touch_left = v
func set_touch_right(v: Vector2) -> void: touch_right = v

func _check_joystick() -> void:
	if Input.get_connected_joypads().size() > 0:
		joystick_connected = true
		mode = InputMode.RC_CONTROLLER

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	joystick_connected = connected
	if connected:
		mode = InputMode.RC_CONTROLLER
	else:
		mode = InputMode.TOUCH
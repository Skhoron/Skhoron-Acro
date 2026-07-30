extends CanvasLayer

# FPV OSD - точная копия реального Betaflight OSD

var enabled: bool = true
var battery: Node
var drone: Node
var streak: Node
var telemetry: Node

# UI элементы
@onready var lbl_voltage: Label = $TopBar/Voltage
@onready var lbl_throttle: Label = $TopBar/Throttle
@onready var lbl_timer: Label = $TopBar/Timer
@onready var lbl_rssi: Label = $TopBar/RSSI
@onready var lbl_altitude: Label = $BottomBar/Altitude
@onready var lbl_speed: Label = $BottomBar/Speed
@onready var lbl_mode: Label = $BottomBar/Mode
@onready var lbl_streak: Label = $Center/StreakMultiplier
@onready var bar_throttle: ProgressBar = $SideBar/ThrottleBar
@onready var vibe_overlay: ColorRect = $VibeOverlay

var flight_timer: float = 0.0
var is_running: bool = false
var prop_damage: Node

func _ready() -> void:
	battery = get_node_or_null("../BatteryModel")
	drone = get_node_or_null("../")
	streak = get_node_or_null("../StreakSystem")
	telemetry = get_node_or_null("../TelemetrySystem")
	prop_damage = get_node_or_null("../PropDamage")

func _process(delta: float) -> void:
	if not enabled:
		visible = false
		return
	visible = true

	if is_running:
		flight_timer += delta

	_update_voltage()
	_update_throttle()
	_update_timer()
	_update_position()
	_update_streak()
	_update_vibration()

func _update_voltage() -> void:
	if battery:
		var v = battery.get_voltage()
		lbl_voltage.text = "%.1fV" % v
		# Красный если низкий
		lbl_voltage.modulate = Color.RED if v < 14.0 else Color.WHITE

func _update_throttle() -> void:
	if drone:
		var thr = int(maxf(0.0, (drone.cmd_throttle + 1.0) / 2.0 * 100.0))
		lbl_throttle.text = "THR %d%%" % thr
		bar_throttle.value = thr

func _update_timer() -> void:
	var mins = int(flight_timer / 60)
	var secs = int(fmod(flight_timer, 60))
	lbl_timer.text = "%02d:%02d" % [mins, secs]

func _update_position() -> void:
	if drone:
		lbl_altitude.text = "ALT %.1fm" % drone.global_position.y
		lbl_speed.text = "SPD %dkm/h" % int(drone.linear_velocity.length() * 3.6)

func _update_streak() -> void:
	if streak:
		var mult = streak.get_multiplier()
		if mult > 1.0:
			lbl_streak.text = "x%.1f" % mult
			lbl_streak.visible = true
			# Пульсация при высоком множителе
			var pulse = 0.8 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
			lbl_streak.modulate.a = pulse
		else:
			lbl_streak.visible = false

func _update_vibration() -> void:
	if prop_damage:
		var vibe = prop_damage.get_vibration()
		if vibe > 0.1:
			var offset = Vector2(
				randf_range(-vibe * 3, vibe * 3),
				randf_range(-vibe * 3, vibe * 3)
			)
			vibe_overlay.position = offset
			vibe_overlay.modulate.a = vibe * 0.3
		else:
			vibe_overlay.modulate.a = 0.0

func start() -> void:
	is_running = true
	flight_timer = 0.0

func stop() -> void:
	is_running = false

func set_enabled(val: bool) -> void:
	enabled = val

func set_flight_mode(mode: String) -> void:
	lbl_mode.text = mode
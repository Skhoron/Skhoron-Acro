extends Node

# Motor temperature simulation
# High temp → reduced power, potential shutdown

var temps: Array[float] = [25.0, 25.0, 25.0, 25.0]  # Celsius
var ambient_temp: float = 25.0

const HEAT_RATE: float = 0.8       # deg/s per unit throttle
const COOL_RATE: float = 0.3       # deg/s passive cooling
const WARN_TEMP: float = 70.0
const SHUTDOWN_TEMP: float = 90.0
const MAX_THROTTLE_SCALE_TEMP: float = 80.0

signal motor_overheat(motor_index: int, temp: float)

var drone_physics: Node

func _ready() -> void:
	drone_physics = get_parent()

func _physics_process(delta: float) -> void:
	var rpms = drone_physics.get_motor_rpms()
	for i in 4:
		var load = rpms[i] / 35000.0  # normalize
		var heat = load * load * HEAT_RATE
		var cool = (temps[i] - ambient_temp) * COOL_RATE
		temps[i] += (heat - cool) * delta
		temps[i] = maxf(temps[i], ambient_temp)

		if temps[i] >= SHUTDOWN_TEMP:
			emit_signal("motor_overheat", i, temps[i])

func get_throttle_scale(motor_index: int) -> float:
	var t = temps[motor_index]
	if t < WARN_TEMP:
		return 1.0
	elif t >= SHUTDOWN_TEMP:
		return 0.0
	return lerpf(1.0, 0.4, (t - WARN_TEMP) / (SHUTDOWN_TEMP - WARN_TEMP))

func get_temps() -> Array[float]:
	return temps

func reset() -> void:
	for i in 4:
		temps[i] = ambient_temp
extends Node

var enabled: bool = true
var base_wind: Vector3 = Vector3.ZERO
var gust: Vector3 = Vector3.ZERO
var gust_timer: float = 0.0
var gust_duration: float = 0.0
var next_gust_in: float = 5.0

var max_base_wind: float = 2.0
var max_gust_speed: float = 6.0

signal gust_started(direction: Vector3, speed: float)

func _ready() -> void:
	_randomize_base_wind()

func _process(delta: float) -> void:
	if not enabled:
		gust = Vector3.ZERO
		return

	gust_timer += delta
	if gust_timer >= next_gust_in:
		gust_timer = 0.0
		next_gust_in = randf_range(3.0, 8.0)
		gust_duration = randf_range(0.5, 2.0)
		var dir = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
		var speed = randf_range(max_gust_speed * 0.3, max_gust_speed)
		gust = dir * speed
		emit_signal("gust_started", dir, speed)

	if gust_timer > gust_duration:
		gust = gust.lerp(Vector3.ZERO, delta * 2.0)

func get_wind_force(drone_mass: float) -> Vector3:
	if not enabled:
		return Vector3.ZERO
	return (base_wind + gust) * drone_mass

func _randomize_base_wind() -> void:
	var dir = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
	base_wind = dir * randf_range(0, max_base_wind)

func set_enabled(val: bool) -> void:
	enabled = val
	if not enabled:
		base_wind = Vector3.ZERO
		gust = Vector3.ZERO
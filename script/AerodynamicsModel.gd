extends Node

# Applied on top of DronePhysics base drag

var drone: RigidBody3D

# Prop wash - turbulence when reversing throttle quickly
var prop_wash_intensity: float = 0.0
var prev_throttle: float = 0.0
const PROP_WASH_DECAY: float = 0.8

# Wind
var wind_vector: Vector3 = Vector3.ZERO
var wind_gust_timer: float = 0.0
var wind_gust_interval: float = 3.0
var max_wind_speed: float = 3.0

func _ready() -> void:
	drone = get_parent()

func _physics_process(delta: float) -> void:
	_update_prop_wash(delta)
	_update_wind(delta)
	_apply_aerodynamics()

func _update_prop_wash(delta: float) -> void:
	var current_throttle = drone.cmd_throttle
	var throttle_delta = absf(current_throttle - prev_throttle)
	if throttle_delta > 0.3:
		prop_wash_intensity = clampf(prop_wash_intensity + throttle_delta * 2.0, 0.0, 1.0)
	prop_wash_intensity = lerpf(prop_wash_intensity, 0.0, PROP_WASH_DECAY * delta)
	prev_throttle = current_throttle

func _update_wind(delta: float) -> void:
	wind_gust_timer -= delta
	if wind_gust_timer <= 0.0:
		wind_gust_timer = wind_gust_interval + randf_range(-1.0, 1.0)
		var gust_dir = Vector3(randf_range(-1, 1), randf_range(-0.1, 0.1), randf_range(-1, 1)).normalized()
		wind_vector = gust_dir * randf_range(0.0, max_wind_speed)

func _apply_aerodynamics() -> void:
	if not drone:
		return

	# Prop wash: random force perturbation
	if prop_wash_intensity > 0.05:
		var wash = Vector3(
			randf_range(-1, 1),
			randf_range(-0.5, 0.5),
			randf_range(-1, 1)
		) * prop_wash_intensity * 0.5
		drone.apply_central_force(wash)

	# Wind force
	if wind_vector.length() > 0.01:
		drone.apply_central_force(wind_vector * drone.mass)

func get_prop_wash_intensity() -> float:
	return prop_wash_intensity

func get_wind_vector() -> Vector3:
	return wind_vector

func set_wind_enabled(enabled: bool) -> void:
	if not enabled:
		wind_vector = Vector3.ZERO
		wind_gust_timer = 9999.0
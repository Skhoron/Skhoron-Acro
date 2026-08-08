extends Node

enum CameraMode {
	FPV,
	THIRD_PERSON_REAR,
	THIRD_PERSON_FRONT,
	ORBIT,
	CINEMATIC,
	FIXED,
	DIRECTOR
}

var mode: CameraMode = CameraMode.FPV
var drone: Node3D
var camera: Camera3D

# Third person
var tp_distance: float = 1.5
var tp_height: float = 0.4
var tp_smoothing: float = 8.0

# Orbit
var orbit_angle: float = 0.0
var orbit_radius: float = 3.0
var orbit_height: float = 1.0

# Cinematic
var cinematic_lag: float = 0.15
var cinematic_vel: Vector3 = Vector3.ZERO

# Fixed
var fixed_points: Array[Vector3] = []
var fixed_index: int = 0

# Director auto-switch timer
var director_timer: float = 0.0
var director_interval: float = 4.0

# FPV
var fpv_cam_angle: float = 30.0  # degrees tilt
var fpv_fov: float = 110.0

func _ready() -> void:
	camera = get_node("../Camera3D")
	drone = get_node("../")

func _process(delta: float) -> void:
	match mode:
		CameraMode.FPV:
			_update_fpv()
		CameraMode.THIRD_PERSON_REAR:
			_update_tp_rear(delta)
		CameraMode.THIRD_PERSON_FRONT:
			_update_tp_front(delta)
		CameraMode.ORBIT:
			_update_orbit(delta)
		CameraMode.CINEMATIC:
			_update_cinematic(delta)
		CameraMode.FIXED:
			_update_fixed()
		CameraMode.DIRECTOR:
			_update_director(delta)

func _update_fpv() -> void:
	camera.fov = fpv_fov
	camera.global_position = drone.global_position + Vector3(0, 0.02, 0)
	camera.global_rotation = drone.global_rotation
	camera.rotation.x += deg_to_rad(fpv_cam_angle)

func _update_tp_rear(delta: float) -> void:
	camera.fov = 75.0
	var target = drone.global_position - drone.global_transform.basis.z * tp_distance + Vector3(0, tp_height, 0)
	camera.global_position = camera.global_position.lerp(target, tp_smoothing * delta)
	camera.look_at(drone.global_position, Vector3.UP)

func _update_tp_front(delta: float) -> void:
	camera.fov = 75.0
	var target = drone.global_position + drone.global_transform.basis.z * tp_distance + Vector3(0, tp_height, 0)
	camera.global_position = camera.global_position.lerp(target, tp_smoothing * delta)
	camera.look_at(drone.global_position, Vector3.UP)

func _update_orbit(delta: float) -> void:
	camera.fov = 70.0
	orbit_angle += delta * 30.0
	var x = cos(deg_to_rad(orbit_angle)) * orbit_radius
	var z = sin(deg_to_rad(orbit_angle)) * orbit_radius
	camera.global_position = drone.global_position + Vector3(x, orbit_height, z)
	camera.look_at(drone.global_position, Vector3.UP)

func _update_cinematic(delta: float) -> void:
	camera.fov = 60.0
	var target = drone.global_position + Vector3(2, 1, 2)
	cinematic_vel = cinematic_vel.lerp(target - camera.global_position, cinematic_lag)
	camera.global_position += cinematic_vel * delta
	camera.look_at(drone.global_position + drone.linear_velocity * 0.3, Vector3.UP)

func _update_fixed() -> void:
	if fixed_points.is_empty():
		return
	camera.global_position = fixed_points[fixed_index]
	camera.look_at(drone.global_position, Vector3.UP)

func _update_director(delta: float) -> void:
	director_timer += delta
	if director_timer >= director_interval:
		director_timer = 0.0
		director_interval = randf_range(3.0, 6.0)
		mode = CameraMode.values()[randi() % (CameraMode.size() - 1)]

func next_mode() -> void:
	var idx = (mode + 1) % CameraMode.size()
	set_mode(idx)

func prev_mode() -> void:
	var idx = (mode - 1 + CameraMode.size()) % CameraMode.size()
	set_mode(idx)

func set_mode(m: int) -> void:
	mode = m as CameraMode

func set_fpv_angle(angle: float) -> void:
	fpv_cam_angle = clampf(angle, 0.0, 60.0)

func set_fpv_fov(fov: float) -> void:
	fpv_fov = clampf(fov, 60.0, 165.0)
	if mode == CameraMode.FPV:
		camera.fov = fpv_fov

func add_fixed_point(pos: Vector3) -> void:
	fixed_points.append(pos)
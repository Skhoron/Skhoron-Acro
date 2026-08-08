extends Node

const REWIND_DURATION: float = 5.0
const RECORD_RATE: float = 60.0  # frames per second stored

var recording: Array = []
var max_frames: int = int(REWIND_DURATION * RECORD_RATE)
var record_timer: float = 0.0
var is_rewinding: bool = false

var drone: RigidBody3D

func _ready() -> void:
	drone = get_parent()

func _physics_process(delta: float) -> void:
	if is_rewinding:
		_apply_rewind()
		return

	record_timer += delta
	if record_timer >= 1.0 / RECORD_RATE:
		record_timer = 0.0
		_record_frame()

func _record_frame() -> void:
	recording.append({
		"pos": drone.global_position,
		"rot": drone.global_rotation,
		"lin_vel": drone.linear_velocity,
		"ang_vel": drone.angular_velocity,
	})
	if recording.size() > max_frames:
		recording.pop_front()

func _apply_rewind() -> void:
	if recording.is_empty():
		stop_rewind()
		return
	var frame = recording.pop_back()
	drone.global_position = frame["pos"]
	drone.global_rotation = frame["rot"]
	drone.linear_velocity = frame["lin_vel"]
	drone.angular_velocity = frame["ang_vel"]

func start_rewind() -> void:
	is_rewinding = true
	drone.freeze = true

func stop_rewind() -> void:
	is_rewinding = false
	drone.freeze = false

func clear() -> void:
	recording.clear()
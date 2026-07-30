extends Node

const RECORD_RATE: float = 60.0

var best_recording: Array = []
var current_recording: Array = []
var record_timer: float = 0.0
var playback_index: int = 0
var is_playing: bool = false

var drone: Node3D
var ghost_mesh: MeshInstance3D

signal playback_finished

func _ready() -> void:
	drone = get_parent()
	_create_ghost_mesh()

func _create_ghost_mesh() -> void:
	ghost_mesh = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.2, 0.05, 0.2)
	ghost_mesh.mesh = mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 0.7, 1.0, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_mesh.material_override = mat
	ghost_mesh.visible = false
	get_tree().current_scene.add_child(ghost_mesh)

func _physics_process(delta: float) -> void:
	if is_playing:
		_update_playback()
		return
	record_timer += delta
	if record_timer >= 1.0 / RECORD_RATE:
		record_timer = 0.0
		current_recording.append({
			"pos": drone.global_position,
			"rot": drone.global_rotation,
		})

func _update_playback() -> void:
	if playback_index >= best_recording.size():
		is_playing = false
		ghost_mesh.visible = false
		emit_signal("playback_finished")
		return
	var frame = best_recording[playback_index]
	ghost_mesh.global_position = frame["pos"]
	ghost_mesh.global_rotation = frame["rot"]
	playback_index += 1

func start_recording() -> void:
	current_recording.clear()

func save_if_best(lap_time: float) -> void:
	# Save current as best (caller should compare times)
	best_recording = current_recording.duplicate()

func start_playback() -> void:
	if best_recording.is_empty():
		return
	playback_index = 0
	is_playing = true
	ghost_mesh.visible = true

func stop_playback() -> void:
	is_playing = false
	ghost_mesh.visible = false
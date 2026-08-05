extends Node

const LESSONS = [
	{ "id": 0, "name": "BASIC CONTROL", "scene": "res://scenes/lessons/lesson_basic.tscn", "unlocked": true },
	{ "id": 1, "name": "HOVERING",       "scene": "res://scenes/lessons/lesson_hover.tscn", "unlocked": false },
	{ "id": 2, "name": "FIGURE 8",       "scene": "res://scenes/lessons/lesson_fig8.tscn",  "unlocked": false },
	{ "id": 3, "name": "GATE RUN",       "scene": "res://scenes/lessons/lesson_gates.tscn", "unlocked": false },
	{ "id": 4, "name": "FREESTYLE INTRO","scene": "res://scenes/lessons/lesson_free.tscn",  "unlocked": false },
]

var medal_system: MedalSystem
var active_lesson_id: int = -1

signal lesson_complete(lesson_id: int, medal: int)

func _ready() -> void:
	medal_system = get_node("/root/MedalSystem")
	_refresh_unlock_state()

func _refresh_unlock_state() -> void:
	for i in LESSONS.size():
		if i == 0:
			LESSONS[i]["unlocked"] = true
			continue
		# Unlock next if previous has at least Bronze
		LESSONS[i]["unlocked"] = medal_system.get_medal(i - 1) >= MedalSystem.Medal.BRONZE

func start_lesson(lesson_id: int) -> void:
	if not LESSONS[lesson_id]["unlocked"]:
		return
	active_lesson_id = lesson_id
	get_tree().change_scene_to_file(LESSONS[lesson_id]["scene"])

func complete_lesson(time: float, accuracy: float, crashes: int) -> MedalSystem.Medal:
	var medal = medal_system.evaluate(active_lesson_id, time, accuracy, crashes)
	_refresh_unlock_state()
	emit_signal("lesson_complete", active_lesson_id, int(medal))
	return medal

func get_lessons() -> Array:
	return LESSONS

func get_lesson(id: int) -> Dictionary:
	return LESSONS[id]

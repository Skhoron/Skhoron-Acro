extends Node

enum Medal { NONE, BRONZE, SILVER, GOLD, PLATINUM }

# Thresholds per lesson [bronze, silver, gold, platinum]
# Format: { "time": seconds, "accuracy": 0-1, "crashes": max }
const LESSON_THRESHOLDS = {
	0: { "bronze": {"time": 60, "crashes": 5}, "silver": {"time": 45, "crashes": 3}, "gold": {"time": 30, "crashes": 1}, "platinum": {"time": 25, "crashes": 0} },
	1: { "bronze": {"time": 90, "crashes": 5}, "silver": {"time": 70, "crashes": 2}, "gold": {"time": 50, "crashes": 1}, "platinum": {"time": 40, "crashes": 0} },
	2: { "bronze": {"accuracy": 0.5, "crashes": 5}, "silver": {"accuracy": 0.7, "crashes": 3}, "gold": {"accuracy": 0.85, "crashes": 1}, "platinum": {"accuracy": 0.95, "crashes": 0} },
	3: { "bronze": {"accuracy": 0.6, "crashes": 4}, "silver": {"accuracy": 0.75, "crashes": 2}, "gold": {"accuracy": 0.9, "crashes": 1}, "platinum": {"accuracy": 1.0, "crashes": 0} },
	4: { "bronze": {"time": 120, "crashes": 5}, "silver": {"time": 90, "crashes": 3}, "gold": {"time": 70, "crashes": 1}, "platinum": {"time": 55, "crashes": 0} },
}

var earned_medals: Array[Medal] = [Medal.NONE, Medal.NONE, Medal.NONE, Medal.NONE, Medal.NONE]

const SAVE_KEY = "medals"

func _ready() -> void:
	_load()

func evaluate(lesson_id: int, time: float, accuracy: float, crashes: int) -> Medal:
	var t = LESSON_THRESHOLDS.get(lesson_id, {})
	var medal = Medal.NONE

	for level in ["bronze", "silver", "gold", "platinum"]:
		var req = t.get(level, {})
		var passed = true
		if req.has("time") and time > req["time"]:
			passed = false
		if req.has("accuracy") and accuracy < req["accuracy"]:
			passed = false
		if req.has("crashes") and crashes > req["crashes"]:
			passed = false
		if passed:
			medal = _medal_from_string(level)

	if medal > earned_medals[lesson_id]:
		earned_medals[lesson_id] = medal
		_save()

	return medal

func get_medal(lesson_id: int) -> Medal:
	return earned_medals[lesson_id]

func get_progress_percent(lesson_id: int) -> float:
	return float(earned_medals[lesson_id]) / float(Medal.PLATINUM) * 100.0

func _medal_from_string(s: String) -> Medal:
	match s:
		"bronze": return Medal.BRONZE
		"silver": return Medal.SILVER
		"gold": return Medal.GOLD
		"platinum": return Medal.PLATINUM
	return Medal.NONE

func _save() -> void:
	var data = []
	for m in earned_medals:
		data.append(int(m))
	var cfg = ConfigFile.new()
	cfg.set_value("medals", "earned", data)
	cfg.save("user://medals.cfg")

func _load() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://medals.cfg") == OK:
		var data = cfg.get_value("medals", "earned", [0,0,0,0,0])
		for i in earned_medals.size():
			earned_medals[i] = data[i] as Medal
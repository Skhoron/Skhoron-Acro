extends Node

const STREAK_INTERVAL: float = 5.0
const MULTIPLIER_STEP: float = 0.05
const MAX_MULTIPLIER: float = 3.0
const MIN_SPEED_THRESHOLD: float = 1.0  # m/s, must be moving

var streak_timer: float = 0.0
var current_multiplier: float = 1.0
var streak_count: int = 0

var drone: RigidBody3D

signal multiplier_changed(value: float)
signal streak_reset

func _ready() -> void:
	drone = get_node("../")

func _process(delta: float) -> void:
	if not drone:
		return
	var speed = drone.linear_velocity.length()
	if speed >= MIN_SPEED_THRESHOLD:
		streak_timer += delta
		if streak_timer >= STREAK_INTERVAL:
			streak_timer = 0.0
			_increment_streak()
	else:
		streak_timer = maxf(streak_timer - delta * 2.0, 0.0)

func _increment_streak() -> void:
	streak_count += 1
	current_multiplier = minf(current_multiplier + MULTIPLIER_STEP, MAX_MULTIPLIER)
	emit_signal("multiplier_changed", current_multiplier)

func reset_streak() -> void:
	streak_timer = 0.0
	current_multiplier = 1.0
	streak_count = 0
	emit_signal("streak_reset")
	emit_signal("multiplier_changed", current_multiplier)

func get_multiplier() -> float:
	return current_multiplier

func get_streak_count() -> int:
	return streak_count
extends Node

# Prop damage affects thrust and causes vibration on OSD

var prop_damage: Array[float] = [0.0, 0.0, 0.0, 0.0]  # 0=intact, 1=destroyed
var vibration_intensity: float = 0.0

signal prop_damaged(motor_index: int, damage: float)

func apply_damage(motor_index: int, impact_force: float) -> void:
	var dmg = clampf(impact_force * 0.3, 0.0, 1.0)
	prop_damage[motor_index] = clampf(prop_damage[motor_index] + dmg, 0.0, 1.0)
	_update_vibration()
	emit_signal("prop_damaged", motor_index, prop_damage[motor_index])

# Returns thrust multiplier [0,1] for a motor
func get_thrust_factor(motor_index: int) -> float:
	return 1.0 - prop_damage[motor_index] * 0.8

func get_vibration() -> float:
	return vibration_intensity

func _update_vibration() -> void:
	vibration_intensity = 0.0
	for d in prop_damage:
		vibration_intensity += d * 0.25

func reset() -> void:
	for i in 4:
		prop_damage[i] = 0.0
	vibration_intensity = 0.0

func get_damage_state() -> Array[float]:
	return prop_damage
extends Node

# 4S LiPo defaults
var cell_count: int = 4
var capacity_mah: float = 1500.0
var c_rating: float = 75.0
var internal_resistance: float = 0.02  # ohms per cell

var voltage_full: float = 4.2
var voltage_nominal: float = 3.7
var voltage_cutoff: float = 3.3

var charge_mah: float = capacity_mah
var current_draw: float = 0.0

signal battery_low(voltage: float)
signal battery_dead

func _ready() -> void:
	charge_mah = capacity_mah

func _physics_process(delta: float) -> void:
	charge_mah -= current_draw * (delta / 3.6)
	if charge_mah <= 0.0:
		charge_mah = 0.0
		emit_signal("battery_dead")
	elif get_voltage() < voltage_cutoff * cell_count:
		emit_signal("battery_low", get_voltage())

func get_voltage() -> float:
	var soc = clampf(charge_mah / capacity_mah, 0.0, 1.0)
	var open_circuit = cell_count * lerpf(voltage_cutoff, voltage_full, soc)
	# Voltage sag under load
	var sag = current_draw * internal_resistance * cell_count
	return maxf(open_circuit - sag, voltage_cutoff * cell_count)

func get_voltage_factor() -> float:
	var nominal = voltage_nominal * cell_count
	return clampf(get_voltage() / nominal, 0.6, 1.1)

func get_current() -> float:
	return current_draw

func get_capacity_percent() -> float:
	return (charge_mah / capacity_mah) * 100.0

func set_current_draw(amps: float) -> void:
	current_draw = clampf(amps, 0.0, capacity_mah * c_rating / 1000.0)

func reset() -> void:
	charge_mah = capacity_mah
	current_draw = 0.0
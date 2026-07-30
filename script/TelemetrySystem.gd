extends Node

const SAMPLE_RATE: float = 10.0  # samples per second

var drone: RigidBody3D
var battery: Node
var motor_temp: Node

var samples: Array = []
var sample_timer: float = 0.0
var flight_time: float = 0.0
var crashes: int = 0
var is_recording: bool = false

var peak_speed: float = 0.0
var peak_altitude: float = 0.0
var peak_throttle: float = 0.0

func _ready() -> void:
	drone = get_node("../")
	battery = get_node("../BatteryModel")
	motor_temp = get_node("../MotorTemperature")

func _process(delta: float) -> void:
	if not is_recording:
		return
	flight_time += delta
	sample_timer += delta

	var speed = drone.linear_velocity.length() * 3.6  # m/s → km/h
	var altitude = drone.global_position.y
	var throttle = maxf(0.0, (drone.cmd_throttle + 1.0) / 2.0 * 100.0)

	peak_speed = maxf(peak_speed, speed)
	peak_altitude = maxf(peak_altitude, altitude)
	peak_throttle = maxf(peak_throttle, throttle)

	if sample_timer >= 1.0 / SAMPLE_RATE:
		sample_timer = 0.0
		samples.append({
			"t": flight_time,
			"speed": speed,
			"altitude": altitude,
			"throttle": throttle,
			"voltage": battery.get_voltage() if battery else 0.0,
		})

func start() -> void:
	is_recording = true
	samples.clear()
	flight_time = 0.0
	crashes = 0
	peak_speed = 0.0
	peak_altitude = 0.0
	peak_throttle = 0.0

func stop() -> void:
	is_recording = false

func register_crash() -> void:
	crashes += 1

func get_summary() -> Dictionary:
	return {
		"flight_time": flight_time,
		"max_speed": peak_speed,
		"max_altitude": peak_altitude,
		"max_throttle": peak_throttle,
		"crashes": crashes,
		"samples": samples,
	}
extends RigidBody3D

# Motor thrust constants (from real datasheets)
# kT: thrust coefficient N/(rad/s)^2
# kQ: torque coefficient Nm/(rad/s)^2
var kT: float = 1.5e-7
var kQ: float = 3.5e-9

# Drone physical parameters
var mass_kg: float = 0.21
var arm_length: float = 0.1  # meters, center to motor
var drone_inertia: Vector3 = Vector3(0.003, 0.003, 0.006)  # kg*m^2

# Motor state [front-left, front-right, rear-left, rear-right]
var motor_rpm: Array[float] = [0.0, 0.0, 0.0, 0.0]
var motor_rpm_target: Array[float] = [0.0, 0.0, 0.0, 0.0]
var motor_spin_directions: Array[int] = [1, -1, -1, 1]  # CCW/CW

# Motor positions relative to center
var motor_positions: Array[Vector3] = [
	Vector3(-arm_length, 0, -arm_length),
	Vector3(arm_length, 0, -arm_length),
	Vector3(-arm_length, 0, arm_length),
	Vector3(arm_length, 0, arm_length)
]

# PID state
var pid_roll: PIDController
var pid_pitch: PIDController
var pid_yaw: PIDController

# Aerodynamics
var drag_coefficient: float = 0.25
var induced_drag: float = 0.05
var ground_effect_height: float = 0.3

# Input commands [-1, 1]
var cmd_throttle: float = 0.0
var cmd_roll: float = 0.0
var cmd_pitch: float = 0.0
var cmd_yaw: float = 0.0

# Battery
var battery: BatteryModel

# Streak multiplier from StreakSystem
var speed_multiplier: float = 1.0

# Motor response time constant (seconds)
const MOTOR_TIME_CONSTANT: float = 0.05

const MAX_RPM: float = 35000.0
const MIN_RPM: float = 0.0

func _ready() -> void:
	mass = mass_kg
	# Применяем кастомный тензор инерции к RigidBody3D.
	# drone_inertia — наша переменная, inertia — встроенное свойство движка.
	inertia = drone_inertia
	pid_roll = PIDController.new(1.2, 0.45, 18.0)
	pid_pitch = PIDController.new(1.2, 0.45, 18.0)
	pid_yaw = PIDController.new(1.8, 0.0, 0.0)
	battery = get_node("../BatteryModel")

func _physics_process(delta: float) -> void:
	_update_motors(delta)
	_apply_forces(delta)

func _update_motors(delta: float) -> void:
	var voltage_factor = battery.get_voltage_factor() if battery else 1.0
	var base_throttle = (cmd_throttle + 1.0) / 2.0  # [-1,1] → [0,1]

	var roll_out = pid_roll.compute(cmd_roll, _get_roll_rate(), delta)
	var pitch_out = pid_pitch.compute(cmd_pitch, _get_pitch_rate(), delta)
	var yaw_out = pid_yaw.compute(cmd_yaw, _get_yaw_rate(), delta)

	# Motor mixing (quadcopter X frame)
	motor_rpm_target[0] = _throttle_to_rpm((base_throttle - roll_out + pitch_out - yaw_out) * voltage_factor * speed_multiplier)
	motor_rpm_target[1] = _throttle_to_rpm((base_throttle + roll_out + pitch_out + yaw_out) * voltage_factor * speed_multiplier)
	motor_rpm_target[2] = _throttle_to_rpm((base_throttle - roll_out - pitch_out + yaw_out) * voltage_factor * speed_multiplier)
	motor_rpm_target[3] = _throttle_to_rpm((base_throttle + roll_out - pitch_out - yaw_out) * voltage_factor * speed_multiplier)

	for i in 4:
		motor_rpm[i] = lerpf(motor_rpm[i], motor_rpm_target[i], delta / MOTOR_TIME_CONSTANT)

func _apply_forces(delta: float) -> void:
	var total_thrust = Vector3.ZERO
	var total_torque = Vector3.ZERO

	for i in 4:
		var omega = motor_rpm[i] * TAU / 60.0  # RPM → rad/s
		var thrust = kT * omega * omega
		var torque_mag = kQ * omega * omega * motor_spin_directions[i]

		var world_thrust = global_transform.basis * Vector3(0, thrust, 0)
		total_thrust += world_thrust

		# Gyroscopic torque from motor spin
		total_torque.y += torque_mag

		# Torque from thrust offset
		var r = motor_positions[i]
		total_torque += r.cross(Vector3(0, thrust, 0))

	# Aerodynamic drag
	var vel = linear_velocity
	var drag = -vel * drag_coefficient * vel.length()
	total_thrust += drag

	# Ground effect - increases lift near ground
	var ground_dist = _get_ground_distance()
	if ground_dist < ground_effect_height:
		var ge_factor = 1.0 + 0.15 * (1.0 - ground_dist / ground_effect_height)
		total_thrust.y *= ge_factor

	apply_central_force(total_thrust)
	apply_torque(total_torque)

func _throttle_to_rpm(throttle: float) -> float:
	return clampf(throttle, 0.0, 1.0) * MAX_RPM

func _get_roll_rate() -> float:
	return angular_velocity.z

func _get_pitch_rate() -> float:
	return angular_velocity.x

func _get_yaw_rate() -> float:
	return angular_velocity.y

func _get_ground_distance() -> float:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * 2.0
	)
	var result = space.intersect_ray(query)
	if result:
		return global_position.distance_to(result.position)
	return 2.0

func set_input(throttle: float, roll: float, pitch: float, yaw: float) -> void:
	cmd_throttle = throttle
	cmd_roll = roll
	cmd_pitch = pitch
	cmd_yaw = yaw

func get_motor_rpms() -> Array[float]:
	return motor_rpm

# Inner PID controller class
class PIDController:
	var kp: float
	var ki: float
	var kd: float
	var integral: float = 0.0
	var prev_error: float = 0.0
	var integral_limit: float = 50.0

	func _init(p: float, i: float, d: float) -> void:
		kp = p
		ki = i
		kd = d

	func compute(setpoint: float, measured: float, delta: float) -> float:
		var error = setpoint - measured
		integral = clampf(integral + error * delta, -integral_limit, integral_limit)
		var derivative = (error - prev_error) / delta if delta > 0 else 0.0
		prev_error = error
		return kp * error + ki * integral + kd * derivative

	func reset() -> void:
		integral = 0.0
		prev_error = 0.0
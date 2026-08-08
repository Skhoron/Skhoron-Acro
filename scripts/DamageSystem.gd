extends Node

# Killzone is 85% of visual mesh size
# Light scrape → prop damage, heavy impact → crash

const KILLZONE_SCALE: float = 0.85
const SCRAPE_FORCE_THRESHOLD: float = 2.0
const CRASH_FORCE_THRESHOLD: float = 8.0

var prop_damage: PropDamage
var streak_system: Node

signal drone_crashed(impact_force: float)
signal drone_scraped(impact_force: float, motor_near: int)

func _ready() -> void:
	prop_damage = get_node("../PropDamage")
	streak_system = get_node("../StreakSystem")

func on_collision(body: Node, impact_velocity: Vector3, contact_point: Vector3) -> void:
	var force = impact_velocity.length()

	if force < SCRAPE_FORCE_THRESHOLD:
		return  # below threshold, ignore

	var nearest_motor = _get_nearest_motor(contact_point)

	if force >= CRASH_FORCE_THRESHOLD:
		emit_signal("drone_crashed", force)
		if streak_system:
			streak_system.reset_streak()
	else:
		# Scrape - damage nearest prop
		prop_damage.apply_damage(nearest_motor, force / CRASH_FORCE_THRESHOLD)
		emit_signal("drone_scraped", force, nearest_motor)

func _get_nearest_motor(point: Vector3) -> int:
	# Motor positions relative to drone center
	var positions = [
		Vector3(-0.1, 0, -0.1),
		Vector3(0.1, 0, -0.1),
		Vector3(-0.1, 0, 0.1),
		Vector3(0.1, 0, 0.1)
	]
	var drone_pos = get_parent().global_position
	var local_point = point - drone_pos
	var nearest = 0
	var min_dist = INF
	for i in 4:
		var dist = local_point.distance_to(positions[i])
		if dist < min_dist:
			min_dist = dist
			nearest = i
	return nearest
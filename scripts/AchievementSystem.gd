extends Node

# Hardcore achievements - no hints shown in game
# Conditions must be discovered through play

enum Achievement {
	FIRST_BLOOD,      # Железо - hover 30s без краша
	GRADUATE,         # Бронза - все 5 уроков академии
	CLEAN_RUN,        # Серебро - полная трасса без краша
	TOP_FIFTY,        # Золото - топ-50 рекорд
	PERFECT_GATE,     # Платина - Gate Run 100% без line assist
	STREAK_MASTER,    # Алмаз - x3.0 streak 3 минуты
	BLIND_CITY,       # Обсидиан - Night City с отключённым OSD
	LAST_BREATH,      # Титан - финиш Desert Canyon < 5% батареи
	RECORD_BREAKER,   # Легенда - топ-1 рекорд
	SUPREME_SECRET,   # Верховный - секрет
}

const ACHIEVEMENT_NAMES = {
	Achievement.FIRST_BLOOD:    "ПЕРВАЯ КРОВЬ",
	Achievement.GRADUATE:       "ВЫПУСКНИК",
	Achievement.CLEAN_RUN:      "ЧИСТЫЙ ЗАХОД",
	Achievement.TOP_FIFTY:      "ТОП-50",
	Achievement.PERFECT_GATE:   "ИДЕАЛЬНЫЙ ПРОХОД",
	Achievement.STREAK_MASTER:  "ПОВЕЛИТЕЛЬ STREAK",
	Achievement.BLIND_CITY:     "СЛЕПОЙ ПОЛЁТ",
	Achievement.LAST_BREATH:    "ПОСЛЕДНИЙ ЗАРЯД",
	Achievement.RECORD_BREAKER: "РЕКОРДСМЕН",
	Achievement.SUPREME_SECRET: "???",
}

# XP reward per achievement
const ACHIEVEMENT_XP = {
	Achievement.FIRST_BLOOD:    100,
	Achievement.GRADUATE:       300,
	Achievement.CLEAN_RUN:      500,
	Achievement.TOP_FIFTY:      800,
	Achievement.PERFECT_GATE:   1200,
	Achievement.STREAK_MASTER:  2000,
	Achievement.BLIND_CITY:     3000,
	Achievement.LAST_BREATH:    4000,
	Achievement.RECORD_BREAKER: 6000,
	Achievement.SUPREME_SECRET: 15000,
}

var unlocked: Array[bool] = []
var rank_system: Node

signal achievement_unlocked(achievement: Achievement, xp_reward: int)

func _ready() -> void:
	unlocked.resize(Achievement.size())
	unlocked.fill(false)
	rank_system = get_node("/root/RankSystem")
	_load()

func check_first_blood(hover_time: float, crashed: bool) -> void:
	if not unlocked[Achievement.FIRST_BLOOD] and hover_time >= 30.0 and not crashed:
		_unlock(Achievement.FIRST_BLOOD)

func check_graduate(lessons_completed: int) -> void:
	if not unlocked[Achievement.GRADUATE] and lessons_completed >= 5:
		_unlock(Achievement.GRADUATE)

func check_clean_run(map_completed: bool, crashes: int) -> void:
	if not unlocked[Achievement.CLEAN_RUN] and map_completed and crashes == 0:
		_unlock(Achievement.CLEAN_RUN)

func check_top_fifty(player_rank: int) -> void:
	if not unlocked[Achievement.TOP_FIFTY] and player_rank <= 50:
		_unlock(Achievement.TOP_FIFTY)

func check_perfect_gate(accuracy: float, line_assist_used: bool) -> void:
	if not unlocked[Achievement.PERFECT_GATE] and accuracy >= 1.0 and not line_assist_used:
		_unlock(Achievement.PERFECT_GATE)

func check_streak_master(max_multiplier: float, duration: float) -> void:
	if not unlocked[Achievement.STREAK_MASTER] and max_multiplier >= 3.0 and duration >= 180.0:
		_unlock(Achievement.STREAK_MASTER)

func check_blind_city(map_id: String, osd_enabled: bool, completed: bool) -> void:
	if not unlocked[Achievement.BLIND_CITY] and map_id == "night_city" and not osd_enabled and completed:
		_unlock(Achievement.BLIND_CITY)

func check_last_breath(map_id: String, battery_pct: float, completed: bool) -> void:
	if not unlocked[Achievement.LAST_BREATH] and map_id == "desert_canyon" and battery_pct < 5.0 and completed:
		_unlock(Achievement.LAST_BREATH)

func check_record_breaker(player_rank: int) -> void:
	if not unlocked[Achievement.RECORD_BREAKER] and player_rank == 1:
		_unlock(Achievement.RECORD_BREAKER)

# Supreme secret - condition intentionally not documented
func check_supreme_secret(condition_met: bool) -> void:
	if not unlocked[Achievement.SUPREME_SECRET] and condition_met:
		_unlock(Achievement.SUPREME_SECRET)

func _unlock(achievement: Achievement) -> void:
	unlocked[int(achievement)] = true
	var xp = ACHIEVEMENT_XP[achievement]
	if rank_system:
		rank_system.add_xp(xp)
	emit_signal("achievement_unlocked", achievement, xp)
	_save()

func is_unlocked(achievement: Achievement) -> bool:
	return unlocked[int(achievement)]

func get_name(achievement: Achievement) -> String:
	return ACHIEVEMENT_NAMES[achievement]

func _save() -> void:
	var cfg = ConfigFile.new()
	var data = []
	for b in unlocked:
		data.append(b)
	cfg.set_value("achievements", "unlocked", data)
	cfg.save("user://achievements.cfg")

func _load() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://achievements.cfg") == OK:
		var data = cfg.get_value("achievements", "unlocked", [])
		for i in min(data.size(), unlocked.size()):
			unlocked[i] = data[i]
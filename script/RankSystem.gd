extends Node

enum Rank {
	IRON, BRONZE, SILVER, GOLD, PLATINUM,
	DIAMOND, OBSIDIAN, TITAN, LEGEND, SUPREME
}

const RANK_NAMES = {
	Rank.IRON:     "ЖЕЛЕЗО",
	Rank.BRONZE:   "БРОНЗА",
	Rank.SILVER:   "СЕРЕБРО",
	Rank.GOLD:     "ЗОЛОТО",
	Rank.PLATINUM: "ПЛАТИНА",
	Rank.DIAMOND:  "АЛМАЗ",
	Rank.OBSIDIAN: "ОБСИДИАН",
	Rank.TITAN:    "ТИТАН",
	Rank.LEGEND:   "ЛЕГЕНДА",
	Rank.SUPREME:  "ВЕРХОВНЫЙ",
}

const RANK_SUBTITLES = {
	Rank.IRON:     "ПЕРВЫЙ ПОЛЁТ",
	Rank.BRONZE:   "НОВИЧОК",
	Rank.SILVER:   "УВЕРЕННЫЙ ПИЛОТ",
	Rank.GOLD:     "ОПЫТНЫЙ ОПЕРАТОР",
	Rank.PLATINUM: "ПРОФЕССИОНАЛ",
	Rank.DIAMOND:  "ЭЛИТА",
	Rank.OBSIDIAN: "АС",
	Rank.TITAN:    "МАСТЕР",
	Rank.LEGEND:   "ЛУЧШИЙ ИЗ ЛУЧШИХ",
	Rank.SUPREME:  "ЛЕГЕНДА FPV",
}

# XP needed to reach each rank
const RANK_XP_THRESHOLDS = {
	Rank.IRON:     0,
	Rank.BRONZE:   500,
	Rank.SILVER:   1500,
	Rank.GOLD:     3500,
	Rank.PLATINUM: 7000,
	Rank.DIAMOND:  13000,
	Rank.OBSIDIAN: 22000,
	Rank.TITAN:    35000,
	Rank.LEGEND:   55000,
	Rank.SUPREME:  99999,
}

# XP card texture paths
const RANK_CARD_TEXTURES = {
	Rank.IRON:     "res://assets/medals/card_iron.png",
	Rank.BRONZE:   "res://assets/medals/card_bronze.png",
	Rank.SILVER:   "res://assets/medals/card_silver.png",
	Rank.GOLD:     "res://assets/medals/card_gold.png",
	Rank.PLATINUM: "res://assets/medals/card_platinum.png",
	Rank.DIAMOND:  "res://assets/medals/card_diamond.png",
	Rank.OBSIDIAN: "res://assets/medals/card_obsidian.png",
	Rank.TITAN:    "res://assets/medals/card_titan.png",
	Rank.LEGEND:   "res://assets/medals/card_legend.png",
	Rank.SUPREME:  "res://assets/medals/card_supreme.png",
}

var current_xp: int = 0
var current_rank: Rank = Rank.IRON

signal rank_up(new_rank: Rank)
signal xp_gained(amount: int, total: int)

func _ready() -> void:
	_load()

func add_xp(amount: int) -> void:
	current_xp += amount
	emit_signal("xp_gained", amount, current_xp)
	_check_rank_up()
	_save()

func _check_rank_up() -> void:
	for rank in range(Rank.SUPREME, -1, -1):
		if current_xp >= RANK_XP_THRESHOLDS[rank] and rank > int(current_rank):
			current_rank = rank as Rank
			emit_signal("rank_up", current_rank)
			break

func get_rank_name() -> String:
	return RANK_NAMES[current_rank]

func get_rank_subtitle() -> String:
	return RANK_SUBTITLES[current_rank]

func get_progress_to_next() -> float:
	if current_rank == Rank.SUPREME:
		return 1.0
	var current_threshold = RANK_XP_THRESHOLDS[current_rank]
	var next_threshold = RANK_XP_THRESHOLDS[int(current_rank) + 1]
	return float(current_xp - current_threshold) / float(next_threshold - current_threshold)

func get_xp_to_next() -> int:
	if current_rank == Rank.SUPREME:
		return 0
	return RANK_XP_THRESHOLDS[int(current_rank) + 1] - current_xp

func get_card_texture_path() -> String:
	return RANK_CARD_TEXTURES[current_rank]

func _save() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("rank", "xp", current_xp)
	cfg.set_value("rank", "rank", int(current_rank))
	cfg.save("user://rank.cfg")

func _load() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://rank.cfg") == OK:
		current_xp = cfg.get_value("rank", "xp", 0)
		current_rank = cfg.get_value("rank", "rank", 0) as Rank
extends Control

@onready var lesson_list: VBoxContainer = $ScrollContainer/LessonList
@onready var btn_back: Button = $Header/BtnBack
@onready var medal_legend: HBoxContainer = $Footer/MedalLegend

var academy: Node
var medal_system: Node

func _ready() -> void:
	academy = get_node_or_null("/root/AcademySystem")
	medal_system = get_node_or_null("/root/MedalSystem")
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	_populate_lessons()

func _populate_lessons() -> void:
	if not academy:
		return
	for lesson in academy.get_lessons():
		var row = _create_lesson_row(lesson)
		lesson_list.add_child(row)

func _create_lesson_row(lesson: Dictionary) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 80)

	# Номер + название
	var num_label = Label.new()
	num_label.text = "%02d %s" % [lesson["id"] + 1, lesson["name"]]
	num_label.custom_minimum_size = Vector2(300, 0)
	row.add_child(num_label)

	# Прогресс бар
	var progress = ProgressBar.new()
	progress.custom_minimum_size = Vector2(200, 20)
	progress.max_value = 100
	if medal_system:
		progress.value = medal_system.get_medal(lesson["id"]) / float(MedalSystem.Medal.PLATINUM) * 100.0
	row.add_child(progress)

	# Медали (4 иконки)
	for tier in ["BRONZE", "SILVER", "GOLD", "PLATINUM"]:
		var medal_icon = TextureRect.new()
		medal_icon.custom_minimum_size = Vector2(32, 32)
		medal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(medal_icon)

	# Кнопка старта если разблокирован
	if lesson["unlocked"]:
		var btn = Button.new()
		btn.text = "START"
		btn.pressed.connect(func(): _start_lesson(lesson["id"]))
		row.add_child(btn)
	else:
		var lock = Label.new()
		lock.text = "🔒"
		row.add_child(lock)

	return row

func _start_lesson(lesson_id: int) -> void:
	if academy:
		academy.start_lesson(lesson_id)
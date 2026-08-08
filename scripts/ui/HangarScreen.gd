extends Control

@onready var grid: GridContainer = $ScrollContainer/DroneGrid
@onready var btn_back: Button = $Header/BtnBack
@onready var lbl_count: Label = $Header/Count

var drone_db: Node
var selected_drone_id: String = "racer_x1"
var drone_card_scene: PackedScene

func _ready() -> void:
	drone_db = get_node_or_null("/root/DroneDatabase")
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
	_populate_grid()

func _populate_grid() -> void:
	if not drone_db:
		return
	var drones = drone_db.get_all()
	lbl_count.text = "%d/12" % drones.size()

	for drone in drones:
		var card = _create_drone_card(drone)
		grid.add_child(card)

func _create_drone_card(drone: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 260)

	var vbox = VBoxContainer.new()
	card.add_child(vbox)

	var name_label = Label.new()
	name_label.text = drone["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	if drone["locked"]:
		var lock = Label.new()
		lock.text = "🔒"
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lock)
	else:
		# 3D превью через SubViewport будет добавлено позже
		var placeholder = ColorRect.new()
		placeholder.custom_minimum_size = Vector2(180, 140)
		placeholder.color = Color(0.1, 0.15, 0.2)
		vbox.add_child(placeholder)

	var specs = Label.new()
	specs.text = "WEIGHT %dg\nMOTORS %s\nPROPS %s" % [
		drone["weight_g"],
		drone["motors"],
		drone["props"]
	]
	specs.add_theme_font_size_override("font_size", 11)
	vbox.add_child(specs)

	if not drone["locked"]:
		var btn = Button.new()
		btn.text = "SELECT"
		btn.pressed.connect(func(): _select_drone(drone["id"]))
		vbox.add_child(btn)

	return card

func _select_drone(drone_id: String) -> void:
	selected_drone_id = drone_id
	var cfg = ConfigFile.new()
	cfg.set_value("session", "drone_id", drone_id)
	cfg.save("user://session.cfg")
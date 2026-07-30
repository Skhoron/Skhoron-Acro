extends Control

@onready var btn_fly: Button = $VBox/BtnFlyFree
@onready var btn_academy: Button = $VBox/BtnAcademy
@onready var btn_hangar: Button = $VBox/BtnHangar
@onready var btn_settings: Button = $VBox/BtnSettings
@onready var lbl_rank: Label = $Header/RankLabel
@onready var lbl_version: Label = $Footer/Version

var rank_system: Node

func _ready() -> void:
	rank_system = get_node_or_null("/root/RankSystem")
	_update_rank_display()

	btn_fly.pressed.connect(_on_fly_pressed)
	btn_academy.pressed.connect(_on_academy_pressed)
	btn_hangar.pressed.connect(_on_hangar_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)

	lbl_version.text = "v0.1.0"

func _update_rank_display() -> void:
	if rank_system:
		lbl_rank.text = rank_system.get_rank_name()

func _on_fly_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map_select.tscn")

func _on_academy_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/academy.tscn")

func _on_hangar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hangar.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
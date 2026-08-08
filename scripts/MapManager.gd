extends Node

const MAPS = [
        {
                "id": "green_hills",
                "name": "GREEN HILLS",
                "difficulty": "EASY",
                "scene": "res://maps/green_hills/green_hills.tscn",
                "preview": "res://assets/textures/maps/green_hills_preview.png",
        },
        {
                "id": "industrial_yard",
                "name": "INDUSTRIAL YARD",
                "difficulty": "MEDIUM",
                "scene": "res://maps/industrial_yard/industrial_yard.tscn",
                "preview": "res://assets/textures/maps/industrial_preview.png",
        },
        {
                "id": "desert_canyon",
                "name": "DESERT CANYON",
                "difficulty": "HARD",
                "scene": "res://maps/desert_canyon/desert_canyon.tscn",
                "preview": "res://assets/textures/maps/desert_preview.png",
        },
        {
                "id": "night_city",
                "name": "NIGHT CITY",
                "difficulty": "EXPERT",
                "scene": "res://maps/night_city/night_city.tscn",
                "preview": "res://assets/textures/maps/night_city_preview.png",
        },
        {
                "id": "arctic_base",
                "name": "ARCTIC BASE",
                "difficulty": "HARD",
                "scene": "res://maps/arctic_base/arctic_base.tscn",
                "preview": "res://assets/textures/maps/arctic_preview.png",
        },
]

var active_map_id: String = ""

func get_all() -> Array:
        return MAPS

func load_map(map_id: String) -> void:
        for m in MAPS:
                if m["id"] == map_id:
                        active_map_id = map_id
                        get_tree().change_scene_to_file(m["scene"])
                        return

func get_active() -> Dictionary:
        for m in MAPS:
                if m["id"] == active_map_id:
                        return m
        return {}
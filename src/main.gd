extends Node3D

var _game_scene : PackedScene = preload("res://src/game.tscn")

func _input(_event: InputEvent) -> void:
    if Input.is_action_just_released("pause"):
        get_tree().quit()

func _ready() -> void:
    add_child(_game_scene.instantiate())

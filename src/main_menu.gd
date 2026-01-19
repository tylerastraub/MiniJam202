extends Node3D

class_name MainMenu

signal advance

func _input(_event: InputEvent) -> void:
    if Input.is_anything_pressed():
        advance.emit()

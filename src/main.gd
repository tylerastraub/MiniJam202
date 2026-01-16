extends Node3D

func _input(_event: InputEvent) -> void:
    if Input.is_action_just_released("pause"):
        get_tree().quit()

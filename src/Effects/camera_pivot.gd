extends Node3D

class_name CameraPivot

signal cameraSpawned

const STARTING_Y : float = 2.0

var _spawn_counter : float = 0.0
var _spawn_speed : float = 2.0
var _spawning : bool = false

func spawn() -> void:
    position.y = STARTING_Y
    _spawn_counter = 0.0
    _spawning = true

func _physics_process(delta: float) -> void:
    _spawn_counter = lerpf(_spawn_counter, 1.0, _spawn_speed * delta)
    rotation.y = deg_to_rad(_spawn_counter * 360)
    position.y = STARTING_Y - STARTING_Y * _spawn_counter
    if _spawning and _spawn_counter > 0.99:
        _spawning = false
        cameraSpawned.emit()

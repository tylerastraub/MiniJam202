extends Node3D

class_name ParryShield

signal lifetimeExpired(shield: ParryShield)

var _lifetime_timer : float = 0.0
var _lifetime : float = 0.2

func _physics_process(delta: float) -> void:
    if _lifetime_timer >= _lifetime:
        lifetimeExpired.emit(self)
    else:
        _lifetime_timer += delta

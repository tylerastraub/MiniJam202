extends Node3D

class_name CriticalText

signal lifetimeExpired(text: CriticalText)

var _lifetime_timer : float = 0.0
var _lifetime : float = 0.8

var _y_drift : float = 0.2

func _physics_process(delta: float) -> void:
    position.y = _y_drift * (_lifetime_timer / _lifetime)
    $Label3D.modulate.a = 1 - (_lifetime_timer / _lifetime)
    $Label3D.outline_modulate.a = 1 - (_lifetime_timer / _lifetime)
    
    if _lifetime_timer >= _lifetime:
        lifetimeExpired.emit(self)
    else:
        _lifetime_timer += delta

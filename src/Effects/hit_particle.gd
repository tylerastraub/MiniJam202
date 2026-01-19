extends Node3D

class_name HitParticle

signal lifetimeExpired(HitParticle: ParryShield)

var _lifetime_timer : float = 0.0
var _lifetime : float = 0.05

func _physics_process(delta: float) -> void:
    if _lifetime_timer >= _lifetime:
        lifetimeExpired.emit(self)
    else:
        _lifetime_timer += delta

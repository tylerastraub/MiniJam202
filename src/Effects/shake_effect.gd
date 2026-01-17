extends Node

class_name ShakeEffect

var max_shake : float = 0.2
var shake_amount : float = 0.0 # scale of 0.0-1.0
var shake_decrement : float = 2.0

func update_shake(delta: float) -> void:
    shake_amount -= shake_decrement * delta
    shake_amount = max(shake_amount, 0.0)

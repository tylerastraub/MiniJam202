extends Node3D

class_name Enemy

var _stats : DuelStats

var _shake : ShakeEffect

func _init() -> void:
    _stats = DuelStats.new()
    _shake = ShakeEffect.new()
    _stats.draw_time = 2.0

func _physics_process(delta: float) -> void:
    var coefficient : float = 1.0 if randi() % 2 else -1.0
    position.x = 2.5 + _shake.max_shake * _shake.shake_amount * coefficient
    _shake.update_shake(delta)

# returns true if action ready to be taken for this turn
func action(timer: float) -> bool:
    if timer > _stats.draw_time and _stats.attacked == false:
        _stats.attacked = true
        return true
    return false

# returns Attack struct containing attack stats
func attack() -> Attack:
    var res : Attack = Attack.new()

    while(randf() < _stats.multi_hit_chance):
        res.num_of_hits += 1
    
    for i in range(res.num_of_hits):
        res.criticals.push_back(randf() < _stats.critical_chance)

    return res

# returns true if successfully defended
func defend() -> bool:
    return randf() < _stats.parry_chance

# if critical == true, one shot kills no matter what
func strike(critical: bool) -> void:
    print("ow i've been struck! i am " + str(self) + ", critical: " + str(critical))
    _shake.shake_amount = 1.0
    if critical:
        _stats.health = 0
    else:
        _stats.health -= 1

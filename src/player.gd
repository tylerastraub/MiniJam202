extends Node3D

class_name Player

var _stats : DuelStats

func _init() -> void:
    _stats = DuelStats.new()

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
    if critical:
        _stats.health = 0
    else:
        _stats.health -= 1

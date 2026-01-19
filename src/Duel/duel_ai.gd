extends Node

class_name DuelAI

enum State {
    NOVAL = -1,
    READY,
    DRAW,
    SHEATH,
    HURT,
    DEAD,
}

var _stats : DuelStats
var _state : State = State.NOVAL
var _last_state : State = State.NOVAL

func ai_init(stats: DuelStats) -> void:
    _stats = stats
    set_state(State.READY)

# returns true if action ready to be taken for this turn
func action(timer: float) -> bool:
    if timer > _stats.draw_time and _stats.attacked == false:
        _stats.attacked = true
        set_state(State.DRAW)
        return true
    return false

# returns Attack struct containing attack stats
func attack() -> Attack:
    var res : Attack = Attack.new()

    if _stats.multi_hit_chance >= 1.0:
        res.num_of_hits = 100
    else:
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
    if critical:
        _stats.health = 0
    else:
        _stats.health -= 1
    set_state(State.HURT)

func set_state(state: State) -> void:
    print("DuelAI.set_state() - changing from " + str(_state) + " to " + str(state))
    if _state == state:
        return
    _last_state = _state
    _state = state

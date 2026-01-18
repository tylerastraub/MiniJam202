extends Node

enum RoundState {
    NOVAL = -1,
    CAMERA_SPAWN,
    READY,
    DUEL,
    WON,
    LOST,
}

@export var _camera_pivot : CameraPivot = null

@export var _player : Player = null
@export var _enemy : Enemy = null
@export var _ready_splash : ReadySplash = null
var _enemy_list : Array[Enemy] = []

var _duel_timer : float = 0.0

var _round_state : RoundState = RoundState.NOVAL

func _ready() -> void:
    _enemy_list.push_back(_enemy)
    _round_state = RoundState.CAMERA_SPAWN
    _camera_pivot.spawn()
    _camera_pivot.cameraSpawned.connect(_on_camera_spawned)
    _ready_splash.call_deferred("start_ready_splash")

func _physics_process(delta: float) -> void:
    if _round_state == RoundState.DUEL:
        duel(delta)
    elif _round_state == RoundState.WON:
        pass
    elif _round_state == RoundState.LOST:
        pass

func duel(delta: float) -> void:
    if _player.get_state() == DuelAI.State.DEAD:
        _round_state = RoundState.LOST
        for enemy in _enemy_list:
            if enemy.get_stats().health > 0:
                enemy._ai._state = DuelAI.State.SHEATH
        return
    
    if _player.action(_duel_timer):
        var p_attack : Attack = _player.attack()
        for i in range(p_attack.num_of_hits):
            if i >= _enemy_list.size():
                break
            if p_attack.criticals[i]:
                _enemy_list[i].strike(true)
            elif _enemy_list[i].defend() == true:
                print("enemy defended!")
            else:
                _enemy_list[i].strike(false)

    var enemies_alive : bool = false
    for enemy in _enemy_list:
        if enemy.get_stats().health < 1:
            if enemy.get_state() == DuelAI.State.HURT:
                enemies_alive = true
            continue
        enemies_alive = true
        if enemy.action(_duel_timer):
            var e_attack : Attack = enemy.attack()
            if e_attack.criticals[0]:
                _player.strike(true)
            elif _player.defend() == true:
                print("player defended!")
            else:
                _player.strike(false)

    if enemies_alive == false:
        print("round won")
        _round_state = RoundState.WON
        _player._ai._state = DuelAI.State.SHEATH

    _duel_timer += delta

func _on_camera_spawned() -> void:
    if _round_state == RoundState.CAMERA_SPAWN:
        _round_state = RoundState.DUEL

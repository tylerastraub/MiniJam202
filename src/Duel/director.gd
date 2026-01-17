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
var _enemy_list : Array[Enemy] = []

var _duel_timer : float = 0.0

var _round_state : RoundState = RoundState.NOVAL

func _ready() -> void:
    _enemy_list.push_back(_enemy)
    _round_state = RoundState.CAMERA_SPAWN
    _camera_pivot.spawn()
    _camera_pivot.cameraSpawned.connect(_on_camera_spawned)

func _physics_process(delta: float) -> void:
    if _round_state == RoundState.DUEL:
        duel(delta)
    if _round_state == RoundState.WON:
        pass

func duel(delta: float) -> void:
    if _player._stats.health < 1:
        _round_state = RoundState.LOST
        return
    
    if _player.action(_duel_timer):
        print("player attack")
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
        if enemy._stats.health < 1:
            continue
        enemies_alive = true
        if enemy.action(_duel_timer):
            print("enemy attack")
            var e_attack : Attack = enemy.attack()
            if e_attack.criticals[0]:
                _player.strike(true)
            elif _player.defend() == true:
                print("player defended!")
            else:
                _player.strike(false)

    if enemies_alive == false:
        _round_state = RoundState.WON

    _duel_timer += delta

func _on_camera_spawned() -> void:
    if _round_state == RoundState.CAMERA_SPAWN:
        _round_state = RoundState.DUEL
        print("time to duel")

extends Node

class_name Director

enum RoundState {
    NOVAL = -1,
    CAMERA_SPAWN,
    READY,
    DUEL,
    WON,
    LOST,
}

signal duelComplete(won: bool, gold_won: int)

@export var _camera_pivot : CameraPivot = null
@export var _player : Player = null
@export var _ready_splash : ReadySplash = null
@export var _round_end_screen : RoundEndScreen = null

var _enemy_scene : PackedScene = preload("res://src/Duel/enemy.tscn")
var _enemy_list : Array[Enemy] = []

var _p_attack : Attack = null

var _duel_timer : float = 0.0
var _multi_attack_delay : float = 0.2
var _multi_attacking : bool = false
var _multi_attack_timer : float = 0.0
var _enemy_attacked : Array[bool] = []

var _round_state : RoundState = RoundState.NOVAL

func start_round() -> void:
    spawn_enemies()
    set_round_state(RoundState.CAMERA_SPAWN)
    _camera_pivot.spawn()
    _camera_pivot.cameraSpawned.connect(_on_camera_spawned)
    _round_end_screen.continuePressed.connect(_on_continue_pressed)
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
        set_round_state(RoundState.LOST)
        for enemy in _enemy_list:
            if enemy.get_stats().health > 0:
                enemy._ai._state = DuelAI.State.SHEATH
        return
    
    if _player.action(_duel_timer):
        _p_attack = _player.attack()
        if _p_attack.num_of_hits > 1:
            _multi_attacking = true
            _multi_attack_timer = 0.0
        else:
            if _p_attack.criticals[0]:
                _enemy_list[0].strike(true)
            elif _enemy_list[0].defend() == true:
                print("enemy defended!")
            else:
                _enemy_list[0].strike(false)
            
    if _multi_attacking:
        for i in range(_p_attack.num_of_hits):
            if i >= _enemy_list.size():
                break
            var multi_attack_index : int = int(_multi_attack_timer / _multi_attack_delay)
            if multi_attack_index >= _enemy_list.size():
                _multi_attacking = false
                break
            elif multi_attack_index != i or _enemy_attacked[i] == true:
                continue
            _enemy_attacked[i] = true
            if _p_attack.criticals[i]:
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
        set_round_state(RoundState.WON)
        _player._ai._state = DuelAI.State.SHEATH

    _multi_attack_timer += delta
    if !_multi_attacking: _duel_timer += delta

func spawn_enemies() -> void:
    var stat_list : Array[DuelStats] = WaveFactory.generate_wave()
    for i in range(stat_list.size()):
        var stat : DuelStats = stat_list[i]
        var enemy : Enemy = _enemy_scene.instantiate()
        add_child(enemy)
        enemy.ai_init(stat)
        enemy._starting_x = 2 + (i * 0.5)
        if i != 0:
            enemy.global_position.z = sin(PI * (i + 0.5))
        _enemy_list.push_back(enemy)
        _enemy_attacked.push_back(false)

func set_round_state(state: RoundState) -> void:
    if state == _round_state:
        return
    _round_state = state
    if _round_state == RoundState.WON:
        var gold_won : int = 0
        for e in _enemy_list:
            gold_won += e.get_stats().bounty
        _round_end_screen.display(true, gold_won)
    elif _round_state == RoundState.LOST:
        _round_end_screen.display(false, _player.get_stats().bounty * -1)

func _on_camera_spawned() -> void:
    if _round_state == RoundState.CAMERA_SPAWN:
        set_round_state(RoundState.DUEL)
        print("begin duel")

func _on_continue_pressed() -> void:
    duelComplete.emit(_round_end_screen._won, _round_end_screen._gold_won)

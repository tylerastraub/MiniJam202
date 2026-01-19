extends Node

class_name Director

enum RoundState {
    NOVAL = -1,
    CAMERA_SPAWN,
    READY,
    DUEL,
    WON,
    LOST,
    DRAW,
}

signal duelComplete(round_result: RoundEndScreen.RoundResult, gold_won: int)

@export var _camera_pivot : CameraPivot = null
@export var _player : Player = null
@export var _ready_splash : ReadySplash = null
@export var _round_end_screen : RoundEndScreen = null

var _parry_shield_scene : PackedScene = preload("res://src/Effects/parry_shield.tscn")

var _enemy_scene : PackedScene = preload("res://src/Duel/enemy.tscn")
var _enemy_list : Array[Enemy] = []

var _p_attack : Attack = null

var _duel_timer : float = 0.0
var _multi_attack_delay : float = 0.2
var _multi_attacking : bool = false
var _multi_attack_timer : float = 0.0
var _enemy_attacked : Array[bool] = []
var _enemies_who_attacked : Array[bool] = []
var _draw_timer : float = 0.0
var _draw_delay : float = 0.5

var _round_state : RoundState = RoundState.NOVAL

func start_round(enemy_stats: Array[DuelStats]) -> void:
    spawn_enemies(enemy_stats)
    set_round_state(RoundState.CAMERA_SPAWN)
    _camera_pivot.spawn()
    _camera_pivot.cameraSpawned.connect(_on_camera_spawned)
    _round_end_screen.continuePressed.connect(_on_continue_pressed)
    _ready_splash.call_deferred("start_ready_splash")

func _physics_process(delta: float) -> void:
    if _round_state == RoundState.DUEL:
        duel(delta)
    elif _round_state == RoundState.DRAW:
        _draw_timer += delta
        if _draw_timer >= _draw_delay and _round_end_screen._display == false:
            _round_end_screen.display(RoundEndScreen.RoundResult.DRAW)
            _player.set_state(DuelAI.State.SHEATH)
            for e in _enemy_list:
                e.set_state(DuelAI.State.SHEATH)

func duel(delta: float) -> void:
    if _player.get_state() == DuelAI.State.DEAD:
        set_round_state(RoundState.LOST)
        for enemy in _enemy_list:
            if enemy.get_stats().health > 0:
                enemy.set_state(DuelAI.State.SHEATH)
        return
    
    var enemies_attacking = false
    for e in _enemies_who_attacked:
        if e == false:
            enemies_attacking = true
            break
    
    if _player.action(_duel_timer) and _player.get_state() != DuelAI.State.HURT:
        _p_attack = _player.attack()
        if _p_attack.num_of_hits > 1:
            _multi_attacking = true
            _multi_attack_timer = 0.0
        else:
            $SwordSwingAudio.play()
            if _p_attack.criticals[0]:
                _enemy_list[0].strike(true)
                $SwordHitAudio.play()
            elif _enemy_list[0].defend() == true:
                print("enemy defended!")
                create_parry_shield(_enemy_list[0])
            else:
                _enemy_list[0].strike(false)
                $SwordHitAudio.play()
            
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
            $SwordSwingAudio.play()
            _enemy_attacked[i] = true
            if _p_attack.criticals[i]:
                _enemy_list[i].strike(true)
                $SwordHitAudio.play()
            elif _enemy_list[i].defend() == true:
                print("enemy defended!")
                create_parry_shield(_enemy_list[i])
            else:
                _enemy_list[i].strike(false)
                $SwordHitAudio.play()

    var enemies_alive : bool = false
    for i in range(_enemy_list.size()):
        var enemy := _enemy_list[i]
        if enemy.get_stats().health < 1:
            if enemy.get_state() == DuelAI.State.HURT:
                enemies_alive = true
            else:
                _enemies_who_attacked[i] = true
            continue
        enemies_alive = true
        if enemy.action(_duel_timer):
            $SwordSwingAudio.play()
            _enemies_who_attacked[i] = true
            var e_attack : Attack = enemy.attack()
            if e_attack.criticals[0]:
                _player.strike(true)
                $SwordHitAudio.play()
            elif _player.defend() == true:
                print("player defended!")
                create_parry_shield(_player)
            else:
                _player.strike(false)
                $SwordHitAudio.play()

    if enemies_alive == false:
        print("round won")
        set_round_state(RoundState.WON)
        _player.set_state(DuelAI.State.SHEATH)
    
    if enemies_attacking == false and _player.get_stats().health > 0 and enemies_alive:
        set_round_state(RoundState.DRAW)
    
    _multi_attack_timer += delta
    if !_multi_attacking: _duel_timer += delta

func spawn_enemies(enemy_stats: Array[DuelStats]) -> void:
    for i in range(enemy_stats.size()):
        var stat : DuelStats = enemy_stats[i]
        var enemy : Enemy = _enemy_scene.instantiate()
        add_child(enemy)
        enemy.ai_init(stat)
        enemy._starting_x = 2 + (i * 0.5)
        if i != 0:
            enemy.global_position.z = sin(PI * (i + 0.5))
        _enemy_list.push_back(enemy)
        _enemy_attacked.push_back(false)
        _enemies_who_attacked.push_back(false)

func set_round_state(state: RoundState) -> void:
    if state == _round_state:
        return
    _round_state = state
    if _round_state == RoundState.WON:
        var gold_won : int = 0
        for e in _enemy_list:
            gold_won += e.get_stats().bounty
        _round_end_screen.display(RoundEndScreen.RoundResult.WON, gold_won)
    elif _round_state == RoundState.LOST:
        _round_end_screen.display(RoundEndScreen.RoundResult.LOST, _player.get_stats().bounty * -1)

func create_parry_shield(user: Node3D) -> void:
    var shield : ParryShield = _parry_shield_scene.instantiate()
    add_child(shield)
    shield.global_position = user.global_position
    shield.lifetimeExpired.connect(_on_parry_shield_lifetime_expired)

func _on_parry_shield_lifetime_expired(shield: ParryShield):
    remove_child(shield)

func _on_camera_spawned() -> void:
    if _round_state == RoundState.CAMERA_SPAWN:
        set_round_state(RoundState.DUEL)
        print("begin duel")

func _on_continue_pressed() -> void:
    duelComplete.emit(_round_end_screen._round_result, _round_end_screen._gold_won)

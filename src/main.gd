extends Node3D

var _game_scene : PackedScene = preload("res://src/game.tscn")
var _upgrade_store_scene : PackedScene = preload("res://src/GUI/upgrade_store.tscn")

var _game : Game = null
var _upgrade_store : UpgradeStore = null

var _player_stats : DuelStats
var _player_gold : int = 100

var _upgrade_costs : Dictionary = {
    UpgradeItem.Type.DRAW_SPEED : 10,
    UpgradeItem.Type.CRITICAL_CHANCE : 10,
    UpgradeItem.Type.MULTI_HIT_CHANCE : 10,
    UpgradeItem.Type.PARRY_CHANCE : 10,
}

var _upgrade_levels : Dictionary = {
    UpgradeItem.Type.DRAW_SPEED : 1.0,
    UpgradeItem.Type.CRITICAL_CHANCE : 1.0,
    UpgradeItem.Type.MULTI_HIT_CHANCE : 1.0,
    UpgradeItem.Type.PARRY_CHANCE : 1.0,
}

func _input(_event: InputEvent) -> void:
    if Input.is_action_just_released("pause"):
        get_tree().quit()
    if Input.is_action_just_released("reload_duel"):
        if _game != null:
            remove_child(_game)
            _game = null
        if _upgrade_store != null:
            remove_child(_upgrade_store)
            _upgrade_store = null
        _game = _game_scene.instantiate()
        _player_stats.attacked = false
        _game.set_player_stats(_player_stats)
        _game.set_player_gold(_player_gold)
        add_child(_game)
        _game.start_round()

func _ready() -> void:
    _player_stats = DuelStats.new()
    
    _upgrade_store = _upgrade_store_scene.instantiate()
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.DRAW_SPEED,
        _player_stats.draw_time,
        _player_stats.draw_time - 0.1,
        get_upgrade_cost(UpgradeItem.Type.DRAW_SPEED),
        _player_gold
    )
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.CRITICAL_CHANCE,
        _player_stats.critical_chance,
        _player_stats.critical_chance + 0.1,
        get_upgrade_cost(UpgradeItem.Type.CRITICAL_CHANCE),
        _player_gold
    )
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.MULTI_HIT_CHANCE,
        _player_stats.multi_hit_chance,
        _player_stats.multi_hit_chance + 0.1,
        get_upgrade_cost(UpgradeItem.Type.MULTI_HIT_CHANCE),
        _player_gold
    )
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.PARRY_CHANCE,
        _player_stats.parry_chance,
        _player_stats.parry_chance + 0.1,
        get_upgrade_cost(UpgradeItem.Type.PARRY_CHANCE),
        _player_gold
    )
    
    _upgrade_store.upgradeBought.connect(_on_upgrade_bought)
    _upgrade_store.nextDuel.connect(_on_next_duel)
    
    add_child(_upgrade_store)

func get_upgrade_cost(type: UpgradeItem.Type) -> int:
    return ceili(_upgrade_levels[type] * _upgrade_costs[type])

func _on_upgrade_bought(type: UpgradeItem.Type, new_value: float, cost: int) -> void:
    _player_gold -= cost
    var coefficient : float = 1.0
    if type == UpgradeItem.Type.DRAW_SPEED:
        _player_stats.draw_time = new_value
        coefficient = -1.0
    elif type == UpgradeItem.Type.CRITICAL_CHANCE:
        _player_stats.critical_chance = new_value
    elif type == UpgradeItem.Type.MULTI_HIT_CHANCE:
        _player_stats.multi_hit_chance = new_value
    elif type == UpgradeItem.Type.PARRY_CHANCE:
        _player_stats.parry_chance = new_value
    _upgrade_levels[type] += 0.1
    _upgrade_store.update_upgrade_item(
        type,
        new_value,
        new_value + 0.1 * coefficient,
        get_upgrade_cost(type),
        _player_gold
    )

func _on_next_duel() -> void:
    _game = _game_scene.instantiate()
    _player_stats.attacked = false
    _game.set_player_stats(_player_stats)
    _game.set_player_gold(_player_gold)
    add_child(_game)
    _game.start_round()
    
    remove_child(_upgrade_store)
    _upgrade_store = null

extends Node3D

var _game_scene : PackedScene = preload("res://src/game.tscn")
var _upgrade_store_scene : PackedScene = preload("res://src/GUI/upgrade_store.tscn")

var _game : Game = null
var _upgrade_store : UpgradeStore = null

var _player_stats : DuelStats
var _player_gold : int = 10000

var _upgrade_costs : Dictionary = {
    UpgradeItem.Type.DRAW_SPEED : 99,
    UpgradeItem.Type.CRITICAL_CHANCE : 99,
    UpgradeItem.Type.MULTI_HIT_CHANCE : 99,
    UpgradeItem.Type.PARRY_CHANCE : 99,
}

var _upgrade_levels : Dictionary = {
    UpgradeItem.Type.DRAW_SPEED : 1.0,
    UpgradeItem.Type.CRITICAL_CHANCE : 1.0,
    UpgradeItem.Type.MULTI_HIT_CHANCE : 1.0,
    UpgradeItem.Type.PARRY_CHANCE : 1.0,
}

var _upgrade_maxes : Dictionary = {
    UpgradeItem.Type.DRAW_SPEED : 0.01,
    UpgradeItem.Type.CRITICAL_CHANCE : 0.99,
    UpgradeItem.Type.MULTI_HIT_CHANCE : 1.0,
    UpgradeItem.Type.PARRY_CHANCE : 0.99,
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
        _on_next_duel()

func _ready() -> void:
    _player_stats = DuelStats.new()
    go_to_shop(_player_stats, _player_gold)

func get_upgrade_cost(type: UpgradeItem.Type) -> int:
    return ceili(10 + (_upgrade_levels[type] - 1.0) * _upgrade_costs[type])

func go_to_shop(stats: DuelStats, gold: int) -> void:
    if _game != null:
        remove_child(_game)
        _game = null
    if _upgrade_store != null:
        remove_child(_upgrade_store)
        _upgrade_store = null
    
    _player_stats = stats
    _player_gold = gold
    _upgrade_store = _upgrade_store_scene.instantiate()
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.DRAW_SPEED,
        _player_stats.draw_time,
        max(_player_stats.draw_time - 0.1, _upgrade_maxes[UpgradeItem.Type.DRAW_SPEED]),
        get_upgrade_cost(UpgradeItem.Type.DRAW_SPEED),
        _player_gold,
        _upgrade_maxes[UpgradeItem.Type.DRAW_SPEED]
    )
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.CRITICAL_CHANCE,
        _player_stats.critical_chance,
        min(_player_stats.critical_chance + 0.1, _upgrade_maxes[UpgradeItem.Type.CRITICAL_CHANCE]),
        get_upgrade_cost(UpgradeItem.Type.CRITICAL_CHANCE),
        _player_gold,
        _upgrade_maxes[UpgradeItem.Type.CRITICAL_CHANCE]
    )
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.MULTI_HIT_CHANCE,
        _player_stats.multi_hit_chance,
        min(_player_stats.multi_hit_chance + 0.1, _upgrade_maxes[UpgradeItem.Type.MULTI_HIT_CHANCE]),
        get_upgrade_cost(UpgradeItem.Type.MULTI_HIT_CHANCE),
        _player_gold,
        _upgrade_maxes[UpgradeItem.Type.MULTI_HIT_CHANCE]
    )
    _upgrade_store.update_upgrade_item(
        UpgradeItem.Type.PARRY_CHANCE,
        _player_stats.parry_chance,
        min(_player_stats.parry_chance + 0.1, _upgrade_maxes[UpgradeItem.Type.PARRY_CHANCE]),
        get_upgrade_cost(UpgradeItem.Type.PARRY_CHANCE),
        _player_gold,
        _upgrade_maxes[UpgradeItem.Type.PARRY_CHANCE]
    )
    
    _upgrade_store.upgradeBought.connect(_on_upgrade_bought)
    _upgrade_store.nextDuel.connect(_on_next_duel)
    
    add_child(_upgrade_store)

func _on_upgrade_bought(type: UpgradeItem.Type, new_value: float, cost: int) -> void:
    _player_gold -= cost
    var next_upgrade : float = 0.0
    if type == UpgradeItem.Type.DRAW_SPEED:
        _player_stats.draw_time = new_value
        next_upgrade = max(new_value - 0.1, _upgrade_maxes[type])
    elif type == UpgradeItem.Type.CRITICAL_CHANCE:
        _player_stats.critical_chance = new_value
        next_upgrade = min(new_value + 0.1, _upgrade_maxes[type])
    elif type == UpgradeItem.Type.MULTI_HIT_CHANCE:
        _player_stats.multi_hit_chance = new_value
        next_upgrade = min(new_value + 0.1, _upgrade_maxes[type])
    elif type == UpgradeItem.Type.PARRY_CHANCE:
        _player_stats.parry_chance = new_value
        next_upgrade = min(new_value + 0.1, _upgrade_maxes[type])
    _upgrade_levels[type] += 0.1
    
    _upgrade_store.update_upgrade_item(
        type,
        new_value,
        next_upgrade,
        get_upgrade_cost(type),
        _player_gold,
        _upgrade_maxes[type]
    )

func _on_next_duel() -> void:
    _game = _game_scene.instantiate()
    _player_stats.attacked = false
    _player_stats.health = 1
    var level_sum : float = 0.0
    for key in _upgrade_levels:
        level_sum += (_upgrade_levels[key] - 1) * 10
    _player_stats.bounty = ceili(10 + level_sum * 4.0 + randi_range(-4, 4))
    _game.set_player_stats(_player_stats)
    _game.set_player_gold(_player_gold)
    _game.returnToShop.connect(go_to_shop)
    add_child(_game)

    if _upgrade_store != null:
        remove_child(_upgrade_store)
        _upgrade_store = null

    _game.start_round()
    
    

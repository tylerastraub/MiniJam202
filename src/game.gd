extends Node3D

class_name Game

signal returnToShop(stats: DuelStats, gold: int)

func _ready() -> void:
    $Director.duelComplete.connect(_on_duel_complete)

func start_round() -> void:
    WaveFactory.base_num_of_enemies = 1
    $Director.start_round()

func set_player_stats(stats: DuelStats) -> void:
    $Player.ai_init(stats)

func set_player_gold(gold: int) -> void:
    $Player._gold = gold

func get_player_stats() -> DuelStats:
    return $Player.get_stats()

func get_player_gold() -> int:
    return $Player._gold

func _on_duel_complete(_won: bool, gold_won: int) -> void:
    var gold : int = get_player_gold()
    gold += gold_won
    set_player_gold(max(gold, 0))
    returnToShop.emit($Player.get_stats(), get_player_gold())

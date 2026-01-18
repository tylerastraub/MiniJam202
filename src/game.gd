extends Node3D

class_name Game

func start_round() -> void:
    WaveFactory.base_num_of_enemies = 5
    $Director.start_round()

func set_player_stats(stats: DuelStats) -> void:
    $Player.ai_init(stats)

func set_player_gold(gold: int) -> void:
    $Player._gold = gold

func get_player_stats() -> DuelStats:
    return $Player._stats

func get_player_gold() -> int:
    return $Player._gold

extends Node3D

class_name Game

func set_player_stats(stats: DuelStats) -> void:
    $Player._stats = stats

func set_player_gold(gold: int) -> void:
    $Player._gold = gold

func get_player_stats() -> DuelStats:
    return $Player._stats

func get_player_gold() -> int:
    return $Player._gold

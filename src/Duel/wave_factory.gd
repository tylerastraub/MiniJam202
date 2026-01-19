extends Node

class_name WaveFactory

var base_num_of_enemies : int = 1

var base_draw_time : float = 2.0
var draw_time_range : float = 0.4

var base_critical_chance : float = 0.05
var critical_chance_range : float = 0.04

var base_parry_chance : float = 0.1
var parry_chance_range : float = 0.04

var base_health : int = 1
var health_range : int = 0

var base_bounty : int = 10

func generate_wave() -> Array[DuelStats]:
    var res : Array[DuelStats] = []

    var num_of_enemies : int = base_num_of_enemies
    @warning_ignore("integer_division")
    var num_of_enemies_range : int = 0 if num_of_enemies == 1 else num_of_enemies / 2 + 1
    if num_of_enemies_range != 0:    
        num_of_enemies -= randi() % num_of_enemies_range # can never go above base_num_of_enemies
    for i in range(num_of_enemies):
        var stats : DuelStats = DuelStats.new()
        stats.draw_time = max(base_draw_time + randf_range(draw_time_range * -1.0, draw_time_range), 0.02)
        stats.critical_chance = min(base_critical_chance + randf_range(critical_chance_range * -1.0, critical_chance_range), 0.99)
        stats.parry_chance = min(base_parry_chance + randf_range(parry_chance_range * -1.0, parry_chance_range), 0.99)
        stats.health = base_health + randi_range(0, health_range)
        @warning_ignore("integer_division")
        stats.bounty = base_bounty + randi_range(base_bounty / -4, base_bounty / 4)
        res.push_back(stats)

    return res

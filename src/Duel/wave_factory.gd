extends Node

class_name WaveFactory

static var base_num_of_enemies : int = 1
static var num_of_enemies_range : int = 0

static var base_draw_time : float = 2.0
static var draw_time_range : float = 0.5

static var base_critical_chance : float = 0.05
static var critical_chance_range : float = 0.04

static var base_parry_chance : float = 0.1
static var parry_chance_range : float = 0.05

static var base_health : int = 1
static var health_range : int = 0

static func generate_wave() -> Array[DuelStats]:
    var res : Array[DuelStats] = []

    var num_of_enemies : int = base_num_of_enemies
    if num_of_enemies_range != 0:    
        num_of_enemies += randi() % num_of_enemies_range
    for i in range(num_of_enemies):
        var stats : DuelStats = DuelStats.new()
        stats.draw_time = base_draw_time + randf_range(draw_time_range * -1.0, draw_time_range)
        stats.critical_chance = base_critical_chance + randf_range(critical_chance_range * -1.0, critical_chance_range)
        stats.parry_chance = base_parry_chance + randf_range(parry_chance_range * -1.0, parry_chance_range)
        stats.health = base_health + randi_range(0, health_range)
        res.push_back(stats)

    return res

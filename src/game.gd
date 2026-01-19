extends Node3D

class_name Game

signal returnToShop(stats: DuelStats, gold: int)

var _wave_factory : WaveFactory = null

func _ready() -> void:
    $Director.duelComplete.connect(_on_duel_complete)
    _wave_factory = WaveFactory.new()

func start_round(player_level: float) -> void:
    scale_difficulty(player_level)
    $Director.start_round(_wave_factory.generate_wave())

func set_player_stats(stats: DuelStats) -> void:
    $Player.ai_init(stats)

func set_player_gold(gold: int) -> void:
    $Player._gold = gold

func get_player_stats() -> DuelStats:
    return $Player.get_stats()

func get_player_gold() -> int:
    return $Player._gold

func scale_difficulty(player_level: float) -> void:
    var enemies_base : float = 1
    var enemies_max : float = 5

    var draw_base : float = 2.0
    var draw_max : float = 1.9
    
    var critical_base : float = 0.05
    var critical_max : float = 0.25

    var parry_base : float = 0.1
    var parry_max : float = 0.4

    var bounty_base : float = 10
    var bounty_max : float = 10

    var max_level : float = 38.0
    var diff_scale : float = player_level / max_level

    _wave_factory.base_num_of_enemies = roundi(enemies_base + enemies_max * diff_scale)
    _wave_factory.base_draw_time = draw_base - draw_max * diff_scale
    _wave_factory.base_critical_chance = critical_base + critical_max * diff_scale
    _wave_factory.base_parry_chance = parry_base + parry_max * diff_scale
    _wave_factory.base_bounty = roundi(bounty_base + bounty_max * diff_scale)

func _on_duel_complete(_round_result: RoundEndScreen.RoundResult, gold_won: int) -> void:
    var gold : int = get_player_gold()
    gold += gold_won
    set_player_gold(max(gold, 0))
    returnToShop.emit($Player.get_stats(), get_player_gold())

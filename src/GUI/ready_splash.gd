extends Control

class_name ReadySplash

var _timer : float = 0.0
var _load_time : float = 2.2
@onready var _load_bar_starting_x : float = $Mask/ReadyLoadBar.position.x
@onready var _load_bar_starting_size_x : float = $Mask/ReadyLoadBar.size.x
var _audio_play_start : float = 0.1
var _audio_played : bool = false

func _ready() -> void:
    $ReadySprite.visible = false
    $Mask/ReadyLoadBar.visible = false

func _physics_process(delta: float) -> void:
    if $ReadySprite.visible == false: return
    $Mask/ReadyLoadBar.position.x = _load_bar_starting_x + _load_bar_starting_size_x * (_timer / _load_time)
    if _timer >= _load_time:
        $ReadySprite.visible = false
        $Mask/ReadyLoadBar.visible = false
    if _timer >= _audio_play_start and _audio_played == false:
        _audio_played = true
        $ReadyAudio.play()
    _timer += delta
    _timer = min(_timer, _load_time)

func start_ready_splash() -> void:
    _timer = 0
    _audio_played = false
    $ReadySprite.visible = true
    $Mask/ReadyLoadBar.visible = true

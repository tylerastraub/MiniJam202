extends Control

class_name RoundEndScreen

signal continuePressed

var _display : bool = false
var _display_timer : float = 0.0
var _display_delay : float = 1.0
var _won : bool = false
var _gold_won : int = 0
var _gold_count : int = 0

func _ready() -> void:
    $Button.pressed.connect(_on_continue_pressed)
    for child in get_children():
        child.visible = false

func _physics_process(delta: float) -> void:
    if _display: update_display()
    _gold_count = int(float(_gold_won) * ((_display_timer - _display_delay) / (_display_delay / 2)))
    if _gold_won < 0:
        _gold_count = max(_gold_count, _gold_won)
    else:
        _gold_count = min(_gold_count, _gold_won)
    _display_timer += delta

func display(won: bool, gold: int = 0) -> void:
    _display = true
    _display_timer = 0
    _won = won
    _gold_won = gold
    _gold_count = 0
    update_display()

func update_display() -> void:
    if _won:
        $WinTexture.visible = true
        $"Lose Texture".visible = false
        if _display_timer >= _display_delay:
            $GoldAmount.visible = true
            $GoldAmount.text = str(_gold_count)
            $GoldIcon.visible = true
        if _display_timer >= _display_delay * 2:
            $Button.position.y = 600
            $Button.visible = true
    else:
        $WinTexture.visible = false
        $"Lose Texture".visible = true
        if _display_timer >= _display_delay:
            $GoldAmount.visible = true
            $GoldAmount.text = "[color=red]" + str(_gold_count)
            $GoldIcon.visible = true
            $GoldAmount.set_size(Vector2(0, 23))
            var gold_bounds : int = $GoldAmount.size.x + $GoldIcon.size.x
            var center : float = get_viewport_rect().size.x / 2.0
            $GoldIcon.position.x = center - gold_bounds / 2.0
            $GoldAmount.position.x = center - gold_bounds / 2.0 + $GoldIcon.size.x
        if _display_timer >= _display_delay * 2:
            $Button.position.y = 600
            $Button.visible = true

func _on_continue_pressed() -> void:
    continuePressed.emit()

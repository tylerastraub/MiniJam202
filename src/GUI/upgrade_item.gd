extends Control

class_name UpgradeItem

enum Type {
    NOVAL = -1,
    DRAW_SPEED,
    CRITICAL_CHANCE,
    MULTI_HIT_CHANCE,
    PARRY_CHANCE,
}

signal upgradeBought(upgrade_item: UpgradeItem)

var _type : Type = Type.NOVAL
var _upgrade_from : float = 0.0
var _upgrade_to : float = 0.0
var _cost : int = 0
var _gold_available : int = -1
var _max_upgrade : float = 1.0

func _ready() -> void:
    $BuyButton.pressed.connect(_on_buy_button_pressed)

func set_type(type: Type) -> void:
    _type = type
    $Icon.region_rect.position.x = 64 * int(_type)
    if _type == Type.DRAW_SPEED:
        $UpgradeTypeLabel.text = "Draw Speed"
        $HintLabel.text = "Increases draw speed"
    elif _type == Type.CRITICAL_CHANCE:
        $UpgradeTypeLabel.text = "Critical Chance"
        $HintLabel.text = "Increases chance of hitting through parries"
    elif _type == Type.MULTI_HIT_CHANCE:
        $UpgradeTypeLabel.text = "Multi-Hit Chance"
        $HintLabel.text = "Increases chance of hitting multiple enemies"
    elif _type == Type.PARRY_CHANCE:
        $UpgradeTypeLabel.text = "Parry Chance"
        $HintLabel.text = "Increases chance of blocking non-critical hits"
    else:
        $UpgradeTypeLabel.text = "NULL"

func set_upgrade_amount(from: float, to: float) -> void:
    _upgrade_from = from
    _upgrade_to = to
    $UpgradeAmountLabel.text = str(snappedf(from, 0.01)) + " → " + str(snappedf(to, 0.01))

func set_cost(cost: int) -> void:
    _cost = cost
    $CostLabel.text = str(cost) + " GOLD"
    $BuyButton.disabled = _gold_available < _cost
    $BuyButton.text = "BUY"
    check_if_maxed()

func set_gold_available(gold_available: int) -> void:
    _gold_available = gold_available
    $BuyButton.disabled = _gold_available < _cost
    $BuyButton.text = "BUY"
    check_if_maxed()

func set_max_upgrade(max_upgrade: float) -> void:
    _max_upgrade = max_upgrade
    check_if_maxed()

func check_if_maxed() -> void:
    if (_upgrade_from <= _max_upgrade and _type == Type.DRAW_SPEED) or ((_upgrade_from > _max_upgrade or is_equal_approx(_upgrade_from, _max_upgrade)) and _type != Type.DRAW_SPEED):
        $BuyButton.disabled = true
        $BuyButton.text = "MAX"
        $CostLabel.visible = false
        $UpgradeAmountLabel.text = "[color=green]" + str(snappedf(_max_upgrade, 0.01))
    else:
        $BuyButton.disabled = _gold_available < _cost
        $BuyButton.text = "BUY"
        $CostLabel.text = str(_cost) + " GOLD"
        $CostLabel.visible = true
        set_upgrade_amount(_upgrade_from, _upgrade_to)

func _on_buy_button_pressed() -> void:
    upgradeBought.emit(self)

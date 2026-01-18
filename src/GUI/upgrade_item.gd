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

func _ready() -> void:
    $BuyButton.pressed.connect(_on_buy_button_pressed)

func set_type(type: Type) -> void:
    _type = type
    $Icon.region_rect.position.x = 64 * int(_type)
    if _type == Type.DRAW_SPEED:
        $UpgradeTypeLabel.text = "Draw Speed"
    elif _type == Type.CRITICAL_CHANCE:
        $UpgradeTypeLabel.text = "Critical Chance"
    elif _type == Type.MULTI_HIT_CHANCE:
        $UpgradeTypeLabel.text = "Multi-Hit Chance"
    elif _type == Type.PARRY_CHANCE:
        $UpgradeTypeLabel.text = "Parry Chance"
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

func set_gold_available(gold_available: int) -> void:
    _gold_available = gold_available
    $BuyButton.disabled = _gold_available < _cost

func _on_buy_button_pressed() -> void:
    upgradeBought.emit(self)

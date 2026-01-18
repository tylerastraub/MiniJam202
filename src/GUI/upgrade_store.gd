extends Node3D

class_name UpgradeStore

signal upgradeBought(type: UpgradeItem.Type, new_value: float, cost: int)
signal nextDuel()

var _upgrade_item_scene : PackedScene = preload("res://src/GUI/upgrade_item.tscn")

var _upgrade_items : Array[UpgradeItem] = []

var _gold : int = 0

func _ready() -> void:
    $CanvasLayer/MarginContainer/StorePanel/NextDuelButton.pressed.connect(_on_next_duel_pressed)

func update_upgrade_item(type: UpgradeItem.Type, from: float, to: float, cost: int, gold_available: int) -> void:
    var upgrade_item : UpgradeItem = null
    for ui in _upgrade_items:
        if ui._type == type:
            upgrade_item = ui
            break
    if upgrade_item == null:
        upgrade_item = _upgrade_item_scene.instantiate()
    upgrade_item.set_type(type)
    upgrade_item.set_upgrade_amount(from, to)
    upgrade_item.set_cost(cost)
    upgrade_item.set_gold_available(gold_available)
    if _upgrade_items.find(upgrade_item) == -1:
        upgrade_item.position.y = _upgrade_items.size() * upgrade_item.size.y
        upgrade_item.upgradeBought.connect(_on_upgrade_bought)
        _upgrade_items.push_back(upgrade_item)
        $CanvasLayer/MarginContainer/StorePanel/UpgradeItems.add_child(upgrade_item)
    _gold = gold_available
    $CanvasLayer/MarginContainer/StorePanel/GoldLabel.text = str(_gold)

func _on_upgrade_bought(upgrade_item: UpgradeItem) -> void:
    _gold -= upgrade_item._cost
    upgradeBought.emit(upgrade_item._type, upgrade_item._upgrade_to, upgrade_item._cost)
    for ui in _upgrade_items:
        ui.set_gold_available(_gold)

func _on_next_duel_pressed() -> void:
    nextDuel.emit()

class_name UpgradesUI
extends MarginContainer

@onready var upgrade_card_1: UpgradeCard = %UpgradeCard1
@onready var upgrade_card_2: UpgradeCard = %UpgradeCard2
@onready var upgrade_card_3: UpgradeCard = %UpgradeCard3

@export var Upgrades: Array[UpgradeResource]

signal chosen(upgrade:UpgradeResource)

func _ready() -> void:
	rollUpgrades(1)
	


func rollUpgrades(_rarity: int):
	var upgradesClone: Array[UpgradeResource] = Upgrades.duplicate()
	for card: UpgradeCard in [upgrade_card_1, upgrade_card_2, upgrade_card_3]:
		var data: UpgradeResource = upgradesClone.pick_random()
		card.setData(data)
		upgradesClone.erase(data)
	
func _on_upgrade_card_1_chosen() -> void:
	chosen.emit(upgrade_card_1.UpgradeData)
	print(upgrade_card_1.UpgradeData.upgradeName)

func _on_upgrade_card_2_chosen() -> void:
	chosen.emit(upgrade_card_2.UpgradeData)
	print(upgrade_card_2.UpgradeData.upgradeName)
	
func _on_upgrade_card_3_chosen() -> void:
	chosen.emit(upgrade_card_3.UpgradeData)
	print(upgrade_card_3.UpgradeData.upgradeName)	

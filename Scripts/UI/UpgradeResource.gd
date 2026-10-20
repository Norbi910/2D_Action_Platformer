class_name UpgradeResource
extends Resource

@export var image: Texture2D
@export var upgradeName: String
@export var description: String
@export var statName: PlayerUtils.UPGRADE_TYPES  = PlayerUtils.UPGRADE_TYPES.NONE
@export var amount: float = 0
@export var abilty: PlayerUtils.ABILITIES = PlayerUtils.ABILITIES.NONE
@export var rarity: int = 1 # 1-5 

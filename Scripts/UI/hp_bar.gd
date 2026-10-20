extends MarginContainer
class_name HpBar

@onready var hp: ColorRect = %hp
@onready var bg: ColorRect = %bg
@export var healthComponent: HealthComponent;

var originalMax: float = 0

var maxHP: float = 0
var currentHP: float = 0

func _ready() -> void:
	if healthComponent:
		setConnections(healthComponent.MAX_HEALTH)

func setConnections(maxhp: float):
	healthComponent.hp_changed.connect(updateHealth)
	healthComponent.max_hp_changed.connect(updateMaxHP)
	originalMax = maxhp
	maxHP = maxhp
	

func updateHealth(health: float):
	currentHP = health
	hp.scale.x = health/originalMax
	

func updateMaxHP(max_health: float, health: float):
	maxHP = max_health
	bg.scale.x = max_health/originalMax
	updateHealth(health)

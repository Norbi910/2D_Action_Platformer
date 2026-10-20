extends CharacterBody2D
class_name Enemy

signal dead

var level: int = 0

@export var baseSpeed: float = 20
@export var speedScalingFactor: float = 1.1
var speed: float
@export var baseMaxHealth: float = 30
@export var healthScalingFactor: float = 1.1
var maxHealth: float
@export var baseDamage: float = 10
@export var damageScalingFactor: float = 1.1
var damage: float

func _ready() -> void:
	level = SceneTransition.loopCount
	speed = baseSpeed * pow(speedScalingFactor, level)
	maxHealth = baseMaxHealth * pow(healthScalingFactor, level)
	damage = baseDamage * pow(damageScalingFactor, level)
	
func set_level(level: int):
	self.level = level 

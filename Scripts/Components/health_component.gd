class_name HealthComponent
extends Node2D

@export var MAX_HEALTH: float = 10.0:
	set(value):
		var diff = value - MAX_HEALTH
		MAX_HEALTH = value
		health = health + diff
		max_hp_changed.emit(MAX_HEALTH, health)
var health: float:
	set(value):
		health = clamp(value, 0, MAX_HEALTH)
		
@export var damage_reduction: float

signal hp_changed(hp: float)
signal max_hp_changed(max_hp: float, hp: float)

func _ready() -> void:
	health = MAX_HEALTH

func damage(dmg: float):
	health -= dmg * clampf(1 - damage_reduction, 0, 1)
	hp_changed.emit(health)

func heal(hp: float):
	health += hp
	hp_changed.emit(health)


	

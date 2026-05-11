extends Node2D
class_name Item

@export var drop_source: Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var item: InventoryItem = preload("res://Resources/Inventory/star.tres")
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	if drop_source:
		drop_source.connect("dead",spawn)

func spawn():
	global_position = drop_source.global_position
	visible = true
	area_2d.monitorable = true

func pickup():
	area_2d.monitorable = false
	animated_sprite_2d.play("pickup")
	
func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

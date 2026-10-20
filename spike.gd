class_name Spike
extends Node2D

@export var damage: float = 10

@onready var attack_component: AttackComponent = %AttackComponent
@onready var collision_shape_2d: CollisionShape2D = %AttackComponent/CollisionShape2D
@onready var spike_body: Node2D = %SpikeBody
@onready var timer: Timer = $Timer

var warn_move_amount:float = -5
var move_amount: float = -10

func _ready() -> void:
	attack_component.ATTACK_DAMAGE = damage
	
var enabled:bool
func attack(duration: float):
	if enabled: return
	enabled = true
	
	var start_pos = global_position
	var warn_target_pos = start_pos
	warn_target_pos.y += warn_move_amount
	var target_pos = start_pos
	target_pos.y += move_amount
	
	var tween = create_tween() 
	tween.tween_property(spike_body, "global_position", warn_target_pos, duration/2)
	await tween.finished
	await get_tree().create_timer(duration/4).timeout
	
	tween = create_tween()
	tween.tween_property(spike_body, "global_position", target_pos, duration/16)
	collision_shape_2d.set_deferred("disabled", false)
	await tween.finished
	
	
	await get_tree().create_timer(duration/8).timeout
	collision_shape_2d.set_deferred("disabled", true)
	
	tween = create_tween()
	tween.tween_property(spike_body, "global_position", start_pos, duration/16)
	await tween.finished
	enabled = false

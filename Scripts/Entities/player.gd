class_name Player
extends CharacterBody2D

# Movement variables
@export var speed: float= 180.0
@export var acceleration: float = 20.0
@export var deacceleration: float = 10.0
var direction: float

@export var jump_height: float = 128.0
@export var jump_time_to_peak: float = 0.6
@export var jump_fall_time: float = 0.43

@onready var jump_velocity: float = - 2.0 * jump_height / jump_time_to_peak
@onready var jump_gravity: float = 2.0 * jump_height / jump_time_to_peak / jump_time_to_peak
@onready var fall_gravity: float = 2.0 * jump_height / jump_fall_time / jump_fall_time

@export var variable_jump_height_strength: float = 0.4
@export var float_strength: float = 10.0
@export var terminal_velocity: float = 600

# Imports
@onready var sprite: Sprite2D = %PlayerSprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var attack_cooldown_timer: Timer = %AttackCooldownTimer
@onready var coyote_timer: Timer = %CoyoteTimer
@onready var jump_buffer_timer: Timer = %JumpBufferTimer
@onready var float_cooldown_timer: Timer = %FloatCooldownTimer
@onready var hit_slow_timer: Timer = %HitSlowTimer
const PLAYER_INVENTORY = preload("res://Resources/Inventory/player_inventory.tres")

signal health_changed(hp)


# State Machine Related variables
enum State{IDLE, RUN, JUMP, FALL, FLOAT}
var current_state: State = State.IDLE
var is_attacking: bool = false
var is_floating: bool = false

var is_alive: bool = true



func _physics_process(delta: float) -> void:
	if not is_alive: return
	jump_velocity = - 2.0 * jump_height / jump_time_to_peak
	jump_gravity= 2.0 * jump_height / jump_time_to_peak / jump_time_to_peak
	fall_gravity= 2.0 * jump_height / jump_fall_time / jump_fall_time
	_handle_input()
	_update_movement(delta)
	_update_state()
	_update_animation()
	move_and_slide()
	#print(velocity.y)
	
func _handle_input():
	if Input.is_action_just_pressed("attack") and attack_cooldown_timer.is_stopped():
		is_attacking = true
		attack_cooldown_timer.start()

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()   # jump Buffer
	
	if current_state == State.JUMP and Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y *= variable_jump_height_strength

	is_floating = not is_on_floor() and Input.is_action_pressed("jump")
	
	if Input.is_action_just_pressed("interact"): 
		_interact()
	
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
	
			
		
		
func _update_movement(delta: float):
	#velocity.x = direction * speed

	# kiting
	if sign(direction) != sign(velocity.x):
		velocity.x = 0

	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration ) # accelerate
	else:
		velocity.x = move_toward(velocity.x, 0, deacceleration ) # deAccelerate

	
	# Able to jump if player is on the ground (coyote timer included) or jump buffered
	if (is_on_floor() or coyote_timer.time_left>0) and jump_buffer_timer.time_left > 0:
		current_state = State.JUMP
		jump_buffer_timer.stop()
		coyote_timer.stop()
		velocity.y = jump_velocity
	
	if current_state == State.JUMP:
		velocity.y += delta * jump_gravity
	elif current_state == State.FLOAT:
		velocity.y += delta * fall_gravity / float_strength
	else: 
		velocity.y += delta * fall_gravity
	velocity.y = minf(velocity.y, terminal_velocity)


func _update_state():
	match current_state:
		State.IDLE when abs(velocity.x) >= speed/10:
			current_state = State.RUN
			
		State.RUN:
			if abs(velocity.x) <= 0:
				current_state = State.IDLE
			if not is_on_floor() and velocity.y >0:
				current_state = State.FALL
				coyote_timer.start()
				
		State.JUMP when velocity.y > 0:
			if is_floating:
				current_state = State.FLOAT
			else:
				current_state = State.FALL
			
		State.FALL:
			if is_on_floor():
				if velocity.x == 0:
					current_state = State.IDLE
				else:
					current_state = State.RUN
			if is_floating and float_cooldown_timer.time_left <= 0:
				current_state = State.FLOAT	
				velocity.y *= 0.1
				float_cooldown_timer.start()
			
		State.FLOAT:
			if not is_floating or is_attacking:
				current_state = State.FALL
				
			if is_on_floor():
				if velocity.x == 0:
					current_state = State.IDLE
				else:
					current_state = State.RUN


func _update_animation() -> void:
	if is_attacking:
		animation_player.play("attack")
	else:
		if velocity.x != 0:
			%Pivot.scale.x = sign(velocity.x)
						
		match current_state:
			State.IDLE: animation_player.play("idle")
			State.RUN: animation_player.play("run")
			State.JUMP: animation_player.play("jump")
			State.FALL: animation_player.play("fall")
			State.FLOAT: animation_player.play("float")


func _die():
	is_alive = false
	PLAYER_INVENTORY.reset()
	animation_player.play("death")
	print("YOU DIED")
	Engine.time_scale = 0.5
	%RespawnTimer.start()

func _interact():
	var interaction_area: Area2D = $Pivot/InteractionArea
	if not interaction_area.has_overlapping_bodies():
		return
	var interactable_body: NPC = interaction_area.get_overlapping_bodies().front()
	interactable_body.interact()
	
func get_max_health() -> float:
	var healthComponent: HealthComponent = %HealthComponent
	if healthComponent:
		return healthComponent.MAX_HEALTH
	return -1

	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false

func _on_respawn_timer_timeout() -> void:
	Engine.time_scale = 1
	is_alive = true
	sprite.visible = true
	get_tree().reload_current_scene()

func _on_hit_box_knockback(force: Vector2) -> void:
	velocity = force
	velocity.y /= 1.6
	current_state = State.JUMP

func _on_hp_changed(hp: float) -> void:
	health_changed.emit(hp)
	if hp <= 0:
		_die()

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickup"):
		var item: Item = area.get_parent()
		PLAYER_INVENTORY.items.push_back(item.item)
		if item.has_method("pickup"):
			item.pickup()
		else: queue_free()


func _on_attack_component_damage_dealt() -> void:
	Engine.time_scale = 0.5
	hit_slow_timer.start()


func _on_hit_slow_timer_timeout() -> void:
	Engine.time_scale = 1

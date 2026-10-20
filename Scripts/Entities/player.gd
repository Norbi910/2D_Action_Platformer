class_name Player
extends CharacterBody2D

# Movement variables
var speed: float
var acceleration: float = 20.0
var deacceleration: float = 10.0
var direction: float

var jump_height: float
var jump_time_to_peak: float = 0.6
var jump_fall_time: float = 0.43

@onready var jump_velocity: float
@onready var doubleJump_velocity: float
@onready var jump_gravity: float
@onready var fall_gravity: float

var variable_jump_height_strength: float = 0.4
var doubleJumpModifier: float = 0.8
var terminal_velocity: float = 600

var float_strength: float = 10.0

var dash_distance: float = 75.0
var dash_velocity: float = 500
@onready var dash_duration: float
 

# Imports
@onready var sprite: Sprite2D = %PlayerSprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var attack_cooldown_timer: Timer = %AttackCooldownTimer
@onready var coyote_timer: Timer = %CoyoteTimer
@onready var jump_buffer_timer: Timer = %JumpBufferTimer
@onready var float_cooldown_timer: Timer = %FloatCooldownTimer
@onready var hit_slow_timer: Timer = %HitSlowTimer
@onready var dash_timer: Timer = %DashTimer
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer

@onready var health_component: HealthComponent = %HealthComponent
@onready var attack_component: AttackComponent = %AttackComponent
@onready var hit_box_component: HitboxComponent = %HitBoxComponent

var playerData: PlayerData
@export var defaultData: PlayerData = preload("uid://c4xbyilpgpniu")

signal health_changed(hp: float)

# Player Abilities
var CanAttack: bool
var CanFloat: bool
var CanDash: bool
var CanDoubleJump: bool
var CanProjectile: bool

# State Machine Related variables
enum State{IDLE, RUN, JUMP, FALL, FLOAT}
var current_state: State = State.IDLE
var is_attacking: bool = false
var is_floating: bool = false
var is_doubleJumping: bool = false
var is_dashing: bool = false
var doubleJumpAvailable: bool = false
var is_alive: bool = true

func _ready() -> void:
	playerData = preload("uid://bvp5o56hskooa")
	defaultData = preload("uid://c4xbyilpgpniu")
	readData()
	jump_velocity = - 2.0 * jump_height / jump_time_to_peak
	jump_gravity= 2.0 * jump_height / jump_time_to_peak / jump_time_to_peak
	fall_gravity= 2.0 * jump_height / jump_fall_time / jump_fall_time
	doubleJump_velocity = - 2.0 * (jump_height * doubleJumpModifier) / jump_time_to_peak
	dash_duration = dash_distance / dash_velocity
	
	Hud.connectPlayer(self)
	SceneTransition.reset.connect(reset)

func readData():
	health_component.MAX_HEALTH = playerData.MaxHealth
	health_component.health = playerData.Health
	attack_component.ATTACK_DAMAGE = playerData.Damage
	hit_box_component.invincibility_time = playerData.IFrames
	speed = playerData.Speed
	jump_height = playerData.JumpHeight
	
	CanAttack = playerData.canAttack
	CanFloat = playerData.canFloat
	CanDoubleJump = playerData.canDoubleJump
	CanDash = playerData.canDash
	CanProjectile = playerData.canProjectile

func saveData():
	playerData.MaxHealth = health_component.MAX_HEALTH
	playerData.Health = health_component.health
	playerData.Damage = attack_component.ATTACK_DAMAGE
	playerData.IFrames = hit_box_component.invincibility_time
	playerData.Speed = speed
	playerData.JumpHeight = jump_height
	
	playerData.canAttack = CanAttack
	playerData.canFloat = CanFloat
	playerData.canDoubleJump = CanDoubleJump
	playerData.canDash = CanDash
	playerData.canProjectile = CanProjectile

func reset():
	health_component.MAX_HEALTH = defaultData.MaxHealth
	health_component.health = defaultData.Health
	attack_component.ATTACK_DAMAGE = defaultData.Damage
	hit_box_component.invincibility_time = defaultData.IFrames
	speed = defaultData.Speed
	jump_height = defaultData.JumpHeight
	
	CanAttack = defaultData.canAttack
	CanFloat = defaultData.canFloat
	CanDoubleJump = defaultData.canDoubleJump
	CanDash = defaultData.canDash
	CanProjectile = defaultData.canProjectile
	saveData()

func _physics_process(delta: float) -> void:
	if not is_alive: return
	_handle_input()
	_update_movement(delta)
	_update_state()
	_update_animation() 
	move_and_slide()
	
func _handle_input():
	if CanAttack and Input.is_action_just_pressed("attack") and attack_cooldown_timer.is_stopped():
		is_attacking = true
		attack_cooldown_timer.start()

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()   # jump Buffer
	
	if current_state == State.JUMP and Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y *= variable_jump_height_strength

	if (is_on_floor() and CanDoubleJump): 
		doubleJumpAvailable = true
		is_doubleJumping = false
	
	is_floating = CanFloat and !is_on_floor() and Input.is_action_pressed("jump")
	
	if Input.is_action_just_pressed("dash") and CanDash and dash_cooldown_timer.is_stopped():
		hit_box_component.invincible(dash_duration)
		dash_timer.start(dash_duration)
		animation_player.pause()
	
	if Input.is_action_just_pressed("interact"): 
		_interact()
	
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
	
		
func _update_movement(delta: float):
	#velocity.x = direction * speed
	if !dash_timer.is_stopped():
		velocity = Vector2(dash_velocity * direction, 0)
		print(velocity.x)
		return
	# kiting
	if sign(direction) != sign(velocity.x):
		velocity.x = 0
		
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration ) # accelerate
	else:
		velocity.x = move_toward(velocity.x, 0, deacceleration ) # deAccelerate

	# Able to jump if player is on the ground (coyote timer included) or jump buffered
	var normalJumpConditon = is_on_floor() or coyote_timer.time_left > 0
	
	if (normalJumpConditon or doubleJumpAvailable) and jump_buffer_timer.time_left > 0:
		current_state = State.JUMP
		jump_buffer_timer.stop()
		coyote_timer.stop()
		
		if (normalJumpConditon): 
			velocity.y = jump_velocity
		else: # doubleJump
			doubleJumpAvailable = false
			velocity.y = doubleJump_velocity
			is_doubleJumping = true	
	
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
	animation_player.play("death")
	SceneTransition.gameOver()
	process_mode = Node.PROCESS_MODE_DISABLED

func _interact():
	var interaction_area: Area2D = $Pivot/InteractionArea
	if not interaction_area.has_overlapping_bodies():
		return
	var interactable_body: NPC = interaction_area.get_overlapping_bodies().front()
	interactable_body.interact()
	
func get_max_health() -> float:
	if health_component:
		return health_component.MAX_HEALTH
	return -1
func get_current_health() -> float:
	return health_component.health

func consumeUpgrade(upgrade: UpgradeResource):
	var amount = upgrade.amount
	match upgrade.statName:
		PlayerUtils.UPGRADE_TYPES.ATK_DMG:
			attack_component.ATTACK_DAMAGE += amount
		PlayerUtils.UPGRADE_TYPES.HP:
			health_component.MAX_HEALTH += amount
		PlayerUtils.UPGRADE_TYPES.SPEED:
			speed += amount
		PlayerUtils.UPGRADE_TYPES.JUMP_HEIGHT:
			jump_height += amount
		PlayerUtils.UPGRADE_TYPES.INV_TIME:
			hit_box_component.invincibility_time += amount
	match upgrade.abilty:
		PlayerUtils.ABILITIES.HOVER:
			CanFloat = true
		PlayerUtils.ABILITIES.DOUBLE_JUMP:
			CanDoubleJump = true
		PlayerUtils.ABILITIES.DASH:
			CanDash = true
		PlayerUtils.ABILITIES.PROJECTILE:
			CanProjectile = true
	saveData()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false

func _on_hit_box_knockback(force: Vector2) -> void:
	velocity = force
	velocity.y /= 1.6
	current_state = State.JUMP

func _on_hp_changed(hp: float) -> void:
	health_changed.emit(hp)
	if hp <= 0:
		_die()
	saveData()

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickup"):
		var item: Item = area.get_parent()
		#PLAYER_INVENTORY.items.push_back(item.item)
		if item.has_method("pickup"):
			item.pickup()
		else: queue_free()


func _on_attack_component_damage_dealt() -> void:
	Engine.time_scale = 0.5
	hit_slow_timer.start()


func _on_hit_slow_timer_timeout() -> void:
	Engine.time_scale = 1


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	dash_cooldown_timer.start()
	animation_player.play()
	

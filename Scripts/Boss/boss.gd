class_name Boss
extends CharacterBody2D

@export var activator_area: Area2D
@export var stats: BossResource

@onready var attack_cooldown: Timer = %AttackCooldown
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player_search_above: ShapeCast2D = %PlayerSearchAbove
@onready var attack_animation_player: AnimationPlayer = %AttackAnimationPlayer
@onready var pivot: Node2D = %Pivot

var state : Util.Boss_State = Util.Boss_State.ON_GROUND
var below_player : bool
var damage: float
var can_change_state: bool = true
var moving_vertically: bool = false

#replace with spawner later
var active: bool
var player_area: Area2D
var player_direction: Vector2
var faciing_dir: float  # 1 is right, -1 left

var target_position: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if activator_area:
		activator_area.connect("area_entered", _on_activator_area_entered)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print_debug(state)
	if not active: return
	if attack_animation_player.is_playing(): return
	handle_visuals()
	#movement
	move(delta)
	#attack
	if (attack_cooldown.time_left <= 0 and !moving_vertically): 
		handle_attack()	
	
	#move_and_slide()
	
func handle_visuals():
	var is_underground = (state == Util.Boss_State.UNDERGROUND) 
	%UnderGroundParticles.emitting = is_underground and !moving_vertically
	
func move(delta: float):
	player_direction = (player_area.global_position - global_position).normalized()
	faciing_dir = player_direction.sign().x
	if faciing_dir:
		pivot.scale.x = -faciing_dir
	target_position.x = player_area.global_position.x
	
	var move_dir: Vector2 = (target_position - global_position).normalized()
	#print(move_dir.sign())
	global_position.y = move_toward(global_position.y, target_position.y, delta * stats.speed )
	
	moving_vertically = target_position.y != global_position.y
	
	if (stats.moveable_states.has(state) and !moving_vertically):
		
		global_position.x = move_toward(global_position.x, target_position.x, delta * stats.speed )
	#print(str(global_position) +" " + str(target_position))

func handle_attack(): 
	var player_above : bool = player_search_above.is_colliding()
	var usableAttacks: Array[Attack]
	for attack: Attack in stats.attacks: 
		if attack == null: continue
		if (attack.isAvailable(state, player_above) and (can_change_state or !attack.isStateChange())): usableAttacks.append(attack)
	if usableAttacks.is_empty(): return
	var chosen_attack : Attack = usableAttacks.pick_random()
	var anim_name : StringName = chosen_attack.animation_name
	damage = chosen_attack.damage
	print(chosen_attack.resource_path)
	if (anim_name != ""): 
		attack_animation_player.play(anim_name)
	else: start_cooldown()
	if (chosen_attack.isStateChange()):
		transition_state(chosen_attack.state_transition)
		can_change_state = false
	else: can_change_state = true

func transition_state(next_state: Util.Boss_State):
	match state: 
		Util.Boss_State.ON_GROUND: 
			match next_state: 
				Util.Boss_State.UNDERGROUND:
					target_position.y += 100
		Util.Boss_State.UNDERGROUND:
			match next_state: 
				Util.Boss_State.ON_GROUND:
					target_position.y -= 100
	state = next_state	
	
	

func _on_activator_area_entered(area: Area2D) -> void:
	active = true
	player_area = area
	target_position = global_position
	start_cooldown()
	print("activated")
	activator_area.disconnect("area_entered", _on_activator_area_entered)

func _on_attack_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET": attack_animation_player.play("RESET")
	else: start_cooldown()
		
func start_cooldown(): 
	var cd := randf_range(stats.cooldown -stats.cooldown_deviation, stats.cooldown + stats.cooldown_deviation)
	attack_cooldown.start(cd)

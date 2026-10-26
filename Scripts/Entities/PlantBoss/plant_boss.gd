class_name PlantBoss
extends CharacterBody2D

@export var arenaShape: CollisionShape2D
@export var player: Player

@export var phase: int = 1
var phaseNodes: Dictionary = {}
# Phase 1
@export_group("Phase 1", "phase1")
@export var phase1_MoveRadius: float = 200
@export var phase1_MoveCooldown: float = 5
@export var phase1_AttackCooldown: float = 10
var phase1Attacks: Array[StringName] = [
	"Shell"
]
@onready var spike_timer: Timer = $Phase1/SpikeTimer

#Phase 2
@export_group("Phase 2", "phase2")
@export var phase2_MoveRadius: float = 100
@export var phase2_MoveCooldown: float = 10
@export var phase2_AttackCooldown: float = 5

#Phase 3
@export_group("Phase 3", "phase3")
@export var phase3_MoveRadius: float = 100
@export var phase3_MoveCooldown: float = 10
@export var phase3_AttackCooldown: float = 5

var tentacleDistance: Dictionary # keyed by side 

@onready var P3RightTentacleCollision_shape_2d: CollisionShape2D = $Phase3/RightTentacle/AttackComponent/CollisionShape2D
@onready var P3LeftTentacleCollision_shape_2d: CollisionShape2D = $Phase3/LeftTentacle/AttackComponent/CollisionShape2D
@onready var P3RightTentacleAttack_enable: Area2D = $Phase3/RightTentacle/AttackEnable
@onready var P3RightTentacleCollision_shape_2d_leaf: CollisionShape2D = $Phase3/RightTentacle/AttackEnable/CollisionShape2DLeaf
@onready var P3LeftTentacleAttack_enable: Area2D = $Phase3/LeftTentacle/AttackEnable
@onready var P3LeftTentacleCollision_shape_2d_leaf: CollisionShape2D = $Phase3/LeftTentacle/AttackEnable/CollisionShape2DLeaf

#Phase 4
@export_group("Phase 4", "phase4")

@onready var phase4Sprite: Sprite2D = $Phase4/Sprite2D


@onready var attack_cooldown: Timer = %AttackCooldown
@onready var move_timer: Timer = %MoveTimer
@onready var health_component: HealthComponent = %HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var phase_1: Node2D = %Phase1
@onready var phase_2: Node2D = %Phase2
@onready var phase_3: Node2D = %Phase3
@onready var phase_4: Node2D = %Phase4

var arenaBoundaries: Rect2
var moveBoundaries: Array[float]

signal thornAttack(duration:float, fill_rate: float)
signal targetedThornAttack(duration:float, center: Vector2, radius:float)
signal allThorn
signal dead
enum Side {LEFT, RIGHT}

func _ready() -> void:
	var localRect: Rect2 = arenaShape.shape.get_rect()
	var globalPos: Vector2 = arenaShape.global_position
	arenaBoundaries = Rect2(localRect.position + globalPos, localRect.size)
	var margin: float = 32
	moveBoundaries = [arenaBoundaries.position.x+margin, arenaBoundaries.end.x-margin]
	print(arenaBoundaries)
	phaseNodes = {
		1: phase_1,
		2: phase_2,
		3: phase_3,
		4: phase_4,
	}
	tentacleDistance = {
		Side.LEFT: P3LeftTentacleCollision_shape_2d.global_position.x - global_position.x,
		Side.RIGHT: P3RightTentacleCollision_shape_2d.global_position.x - global_position.x,
	}
	if phase != 1: switchPhase(1, phase)


func _physics_process(delta: float) -> void:
	
	match phase:
		1: 
			teleportRandomly(phase1_MoveCooldown, phase1_MoveRadius)
			tryToAttack(phase1_AttackCooldown, "Phase1/Shell")
			if spike_timer.is_stopped():
				thornAttack.emit(phase1_AttackCooldown, 0.3)
				spike_timer.start(phase1_AttackCooldown)
		2: 
			teleportRandomly(phase2_MoveCooldown, phase2_MoveRadius)
			tryToAttack(phase2_AttackCooldown, "Phase2/SlamAttack")
		3:
			if move_timer.is_stopped(): 
				var side: Side = Side.values().pick_random()
				var movedSide = teleportNearPlayer(phase3_MoveCooldown, tentacleDistance.get(side), side)
				#if movedSide == -1: return
				#side = movedSide
			if attack_cooldown.is_stopped(): 
				if P3LeftTentacleAttack_enable.has_overlapping_areas():
					await get_tree().create_timer(phase3_AttackCooldown/4).timeout
					tryToAttack(phase3_AttackCooldown, "Phase3/SlamLeft")
					targetedThornAttack.emit(2, Vector2(P3LeftTentacleCollision_shape_2d_leaf.global_position.x, global_position.y), 70)
					return
				if P3RightTentacleAttack_enable.has_overlapping_areas():
					await get_tree().create_timer(phase3_AttackCooldown/4).timeout
					tryToAttack(phase3_AttackCooldown, "Phase3/SlamRight")
					targetedThornAttack.emit(2, Vector2(P3RightTentacleCollision_shape_2d_leaf.global_position.x, global_position.y), 70)
					return
				#tryToAttack(phase3_AttackCooldown, "Phase3/Slam"+Side.keys()[side].capitalize())
				
		4:
			var turnRotation = phase4Sprite.global_position.angle_to_point(player.global_position) + PI/2
			print(turnRotation)
			phase4Sprite.global_rotation = rotate_toward(phase4Sprite.global_rotation, turnRotation , 0.07)
			var direction = (player.global_position - global_position).normalized()
			velocity = velocity.move_toward(direction * 70, 5) 
			move_and_slide()
	
func tryToAttack(attackCD: float, attackname: StringName):
	if !attack_cooldown.is_stopped(): return
	
	animation_player.play(attackname)
	attack_cooldown.start(attackCD)

func teleportRandomly(moveCD: float, moveRadius: float):
	if !move_timer.is_stopped(): return
	
	var left_bound = max(moveBoundaries[0], global_position.x - moveRadius)
	var right_bound = min(moveBoundaries[1], global_position.x + moveRadius)
	print("left: "+str(left_bound)+", right: "+str(right_bound) + ", currpos: " + str(global_position.x))
	global_position.x = randf_range(left_bound, right_bound)
	#TODO add inground movement transition
	move_timer.start(moveCD)
	#attack_cooldown.start()

func teleportNearPlayer(moveCD: float, distance: float, sidePreference: Side) -> int:
	if !move_timer.is_stopped(): return -1
	var playerPosition = player.global_position
	var sidePostionX = {
		Side.LEFT: Vector2(playerPosition.x - distance, global_position.y),
	 	Side.RIGHT: Vector2(playerPosition.x + distance, global_position.y)
	}
	if arenaBoundaries.has_point(sidePostionX.get(sidePreference)):
		global_position.x = sidePostionX.get(sidePreference).x
		move_timer.start(moveCD)
		return sidePreference
	var otherSide = Side.RIGHT if sidePreference == Side.LEFT else Side.LEFT
	if arenaBoundaries.has_point(sidePostionX.get(otherSide)):
		global_position.x = sidePostionX.get(otherSide).x
		move_timer.start(moveCD)
		return otherSide
	return -1
	
func _on_hp_changed(hp: float) -> void:
	var healthPercentage = hp/health_component.MAX_HEALTH
	match phase:
		1 when healthPercentage < 0.75:
			phase = 2
			switchPhase(1,2)
		2 when healthPercentage < 0.25:
			phase = 3
			switchPhase(2, 3)
		3 when healthPercentage < 0.1:
			phase = 4
			switchPhase(3, 4)
		4 when healthPercentage <= 0:
			dead.emit()
			queue_free()

func switchPhase(from: int, to: int):
	var fromNode: Node2D = phaseNodes.get(from)
	var toNode: Node2D = phaseNodes.get(to)
	fromNode.visible = false
	toNode.visible = true
	toNode.process_mode = Node.PROCESS_MODE_INHERIT
	fromNode.process_mode = Node.PROCESS_MODE_DISABLED
	
	match to: 
		2:
			pass
		3:
			pass
		4: 
			health_component.heal(health_component.MAX_HEALTH)
			allThorn.emit()
			$CollisionShape2D.disabled = true
			global_position.y -= 300
	

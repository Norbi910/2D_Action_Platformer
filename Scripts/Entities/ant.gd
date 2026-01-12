extends Enemy


@export var speed: float = 20

@export var max_hp: float
@export var damage: float



var direction: int = 1
@export var is_alive: bool = true
@onready var ray_cast_ahead: RayCast2D = $%RayCastAhead
@onready var ray_cast_down: RayCast2D = $%RayCastDown
@onready var sprite: Sprite2D = $pivot/Sprite2D
@onready var pivot: Node2D = $pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var attack_component: AttackComponent = $pivot/AttackComponent

func _ready() -> void:
	if max_hp:
		health_component.MAX_HEALTH = max_hp
	if damage:
		attack_component.ATTACK_DAMAGE = damage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if not is_alive:
		return 
	if ray_cast_ahead.is_colliding() or not ray_cast_down.is_colliding():
		turn_around()
		
	velocity.x = direction * speed 
	velocity += get_gravity() * _delta
	var ground_following_rotation: float= get_real_velocity().angle_to(Vector2(direction, 0)) * -direction
	sprite.rotation = move_toward(sprite.rotation, ground_following_rotation, 0.1)
	move_and_slide()

func turn_around():
	direction *= -1
	pivot.scale.x = direction

func _on_health_changed(hp: float) -> void:
	if hp <= 0:
		_die()

func _die():
	dead.emit()
	is_alive = false
	$HealthComponent.queue_free()
	$pivot/HitBoxComponent.queue_free()
	$pivot/AttackComponent.queue_free()
	animation_player.play("death")

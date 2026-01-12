extends Node2D
class_name HitFlashComponent

@export var sprite : Sprite2D
@export var healthComponent: HealthComponent
@onready var flash_timer: Timer = $FlashTimer
@export var flash_enabled: bool = false
@export var flash_color: Color = Color.WHITE
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_flashing : bool = false

func _ready() -> void:
	if healthComponent:
		healthComponent.connect("hp_changed", flash)

func _process(_delta: float) -> void:
	if not sprite: 	return
	sprite.material.set_shader_parameter("enabled", flash_enabled)
	sprite.material.set_shader_parameter("color_parameter", flash_color)

func flash(_dmg: float):
	flash_enabled = true
	flash_timer.start()

func toggle_flashing():
	is_flashing = not is_flashing
	if flash_timer.time_left > 0:
		return
	if not is_flashing:
		animation_player.stop()
		flash_color = Color.WHITE
		flash_enabled = false
		return
	flash_enabled = true
	flash_color = Color.RED
	animation_player.play("quick_flash")

func _on_flash_timer_timeout() -> void:
	flash_enabled = false
	if is_flashing and not animation_player.is_playing():
		flash_enabled = true
		flash_color = Color.LIGHT_YELLOW
		animation_player.play("quick_flash")

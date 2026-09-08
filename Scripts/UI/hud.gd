class_name HUD
extends CanvasLayer

var max_health: float

@onready var hp_bar: HpBar = $Control/HPBar
@onready var death_label: Label = $DeathLabel
@onready var win_label: Label = $WinLabel
const PLAYER_DATA = preload("uid://bvyijoa5sha6v")

@export var Player: Player

signal win

func _process(_delta: float) -> void:
	if PLAYER_DATA.completed_quests.has("bunny_star"):
		_win()

func _win():
	win_label.visible = true
	win.emit()

func update(hp: float):
	hp_bar.update(hp/ max_health)
	death_label.visible = hp == 0

signal hints_toggled(state: bool)
func _on_pause_menu_hints_toggle(state: bool) -> void:
	hints_toggled.emit(state)

func _ready() -> void:
	if !Player: return
	Player.connect("health_changed", update)
	max_health = Player.get_max_health()
	

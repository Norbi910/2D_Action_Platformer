extends Node2D

@onready var labels: Control = $Labels

func _on_hud_hints_toggled(state: bool) -> void:
	labels.visible = state

func _on_teleport_area_entered(area: Area2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level_stage_1.tscn")

func _on_hud_win() -> void:
	%Teleport.visible = true
	$Teleport/CollisionShape2D.disabled = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_home"):
		_on_hud_win()

extends Node2D

@onready var labels: Control = $Labels

func _on_hud_hints_toggled(state: bool) -> void:
	labels.visible = state

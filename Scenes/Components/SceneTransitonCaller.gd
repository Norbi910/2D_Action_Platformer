class_name SceneTransitonCaller
extends Area2D

@export_file_path() var nextScene: String

func _on_area_entered(area: Area2D) -> void:
	SceneTransition.switch_scene(nextScene)

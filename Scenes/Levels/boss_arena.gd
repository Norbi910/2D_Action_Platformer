extends Node2D

@onready var spikes: Node2D = $Spikes
@onready var tile_map_layer_2: TileMapLayer = $TileMapLayer2

func randomSpikeAttack(duration:float, fillRate:float):
	for spike: Spike in spikes.get_children():
		if (randf() < fillRate):
			spike.attack(duration)

func targetedRadiusSpikeAttack(duration:float, center: Vector2, radius:float):
	var enabledZone: Rect2 = Rect2(center.x-radius, center.y-radius,radius*2, radius*2 )
	for spike: Spike in spikes.get_children():
		if (center.distance_to(spike.global_position) <= radius):
			spike.attack(duration)

func enableAllThorns(): 
	await ready
	for spike: Spike in spikes.get_children():
		spike.enable()
	await get_tree().create_timer(1).timeout
	tile_map_layer_2.collision_enabled = true
	tile_map_layer_2.visible = true


func _on_portal_area_entered(area): 
	SceneTransition.Loop()


func _on_plant_boss_dead() -> void:
	$TileMapLayer3.visible = false
	$TileMapLayer3.collision_enabled = false

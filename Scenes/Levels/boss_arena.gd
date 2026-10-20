extends Node2D

@onready var spikes: Node2D = $Spikes

func randomSpikeAttack(duration:float, fillRate:float):
	for spike: Spike in spikes.get_children():
		if (randf() < fillRate):
			spike.attack(duration)

func targetedRadiusSpikeAttack(duration:float, center: Vector2, radius:float):
	var enabledZone: Rect2 = Rect2(center.x-radius, center.y-radius,radius*2, radius*2 )
	for spike: Spike in spikes.get_children():
		if (center.distance_to(spike.global_position) <= radius):
			spike.attack(duration)

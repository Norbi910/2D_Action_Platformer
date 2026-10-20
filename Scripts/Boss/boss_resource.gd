class_name BossResource
extends Resource

@export var attacks: Array[Attack]
@export_range(0.5, 10, 0.25) var cooldown: float = 5
@export var cooldown_deviation: float = 1
@export var moveable_states: Array[Util.Boss_State]
@export var speed: float = 50

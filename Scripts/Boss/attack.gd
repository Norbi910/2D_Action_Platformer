class_name Attack
extends Resource

@export var animation_name: StringName
@export var damage: float
@export var required_state: Util.Boss_State
@export var required_under_player: bool
@export var state_transition: Util.Boss_State

func isAvailable(boss_state: Util.Boss_State, under_player: bool) -> bool:
	var under =  !required_under_player or under_player
	return boss_state == required_state and under

func isStateChange() -> bool:
	return state_transition != required_state

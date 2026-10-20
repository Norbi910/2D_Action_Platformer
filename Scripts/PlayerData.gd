class_name PlayerData
extends Resource

@export_category("Stats")
@export var MaxHealth: float
@export var Health: float
@export var Speed: float
@export var Damage: float
@export var IFrames: float
@export var JumpHeight: float

@export_category("Abilities")
@export var canAttack: bool
@export var canFloat: bool
@export var canDoubleJump: bool
@export var canDash: bool
@export var canProjectile: bool

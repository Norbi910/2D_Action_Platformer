extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const startingLevel = "res://Scenes/Levels/DemoLevel.tscn"

func switch_scene(nextScene: String) -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(nextScene)
	await get_tree().process_frame
	animation_player.play("fade_out")
	await animation_player.animation_finished
	newScene.emit()	
	
	
func Loop():
	switch_scene(startingLevel)
	loopCount += 1
	loop.emit()

signal game_over
signal win
signal reset
signal loop
signal newScene
var loopCount: int = 0
	
func gameOver():
	game_over.emit()
	_screenSlowdown()
	
func Win():
	win.emit()
	_screenSlowdown()

func _screenSlowdown(): 
	is_game_over = true
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.2).timeout
	if is_game_over: 
		Engine.time_scale = 0
	
var is_game_over: bool = false

func reset_game():
	is_game_over = false
	get_tree().change_scene_to_file(startingLevel)
	await get_tree().process_frame
	reset.emit()
	Engine.time_scale = 1
	
	
	
	

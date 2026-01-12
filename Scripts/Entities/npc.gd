class_name NPC
extends CharacterBody2D

@onready var text_box: Label = $TextBox
const PLAYER_DATA = preload("uid://bvyijoa5sha6v")
enum QuestState {NONE, ACCEPTED, COMPLETED}
@export var current_state: QuestState = QuestState.NONE

#signal win

func _ready() -> void:
	text_box.visible = false

func interact():	
	if PLAYER_DATA.hasItem("star"):
		current_state = QuestState.COMPLETED
		PLAYER_DATA.completed_quests.append("bunny_star")
		PLAYER_DATA.removeItem("star")
	if text_box.visible:
		talk()
	updateDialogue()
	text_box.visible = true
	
func talk():
	text_box.lines_skipped += 1
	if current_state == QuestState.NONE and text_box.lines_skipped == text_box.get_line_count():
		current_state = QuestState.ACCEPTED
		
		#win.emit()
	text_box.lines_skipped %= text_box.get_line_count()
	
func updateDialogue():
	match current_state:
		QuestState.NONE:
			text_box.text = "Hi!
My name is bun!
Nice to meet you!"
		QuestState.ACCEPTED:
			text_box.text = "Bring me a Star and Come back! 
You'll find it East of here!
It's guarded by a HUGE ANT"
		QuestState.COMPLETED:
			text_box.text = "Thanks for bringing me this star!
So shinyy!
I love it <3"
		

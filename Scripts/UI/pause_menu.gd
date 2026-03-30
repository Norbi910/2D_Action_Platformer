extends Control


@onready var settings_menu: MarginContainer = %SettingsMenu
@onready var base_menu: MarginContainer = %BaseMenu

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if settings_menu.visible: 
			settings_menu.visible = false
			base_menu.visible = true
		elif visible:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true

func _on_resume_button_pressed() -> void:
	settings_menu.visible = false
	base_menu.visible = true
	Input.action_press("pause")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	base_menu.visible = false
	settings_menu.visible = true
	
func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	AudioServer.set_bus_mute(0, (value == %VolumeSlider.min_value))

signal hints_toggle(state: bool)
func _on_hint_button_pressed() -> void:
	hints_toggle.emit(%HintButton.button_pressed)

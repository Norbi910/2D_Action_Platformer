extends CanvasLayer

var player: Player

@onready var hp_bar: HpBar = %HPBar
@onready var death_label: Label = %DeathLabel
@onready var win_label: Label = %WinLabel
@onready var upgrades_ui: UpgradesUI = %UpgradesUI
@onready var end_screen: MarginContainer = %EndScreen
@onready var debug_buttons: VBoxContainer = %DebugButtons


func _ready() -> void:
	SceneTransition.win.connect(_win)
	SceneTransition.game_over.connect(_game_over)
	SceneTransition.newScene.connect(rollUpgrades)

func _win():
	end_screen.visible = true
	win_label.visible = true

func _game_over():
	end_screen.visible = true
	death_label.visible = true
func _reset():
	win_label.visible = false
	death_label.visible = false
	end_screen.visible = false
	SceneTransition.reset_game()
	
func connectPlayer(player: Player):
	self.player = player
	hp_bar.healthComponent = player.health_component
	hp_bar.setConnections(100)
	hp_bar.updateMaxHP(player.get_max_health(), player.get_current_health())
	
func rollUpgrades():
	upgrades_ui.visible = true
	upgrades_ui.rollUpgrades(1)
	Engine.time_scale = 0

func _on_upgrades_ui_chosen(upgrade: UpgradeResource) -> void:
	if !player: return
	player.consumeUpgrade(upgrade)
	upgrades_ui.visible = false
	Engine.time_scale = 1


func _on_button_pressed() -> void:
	rollUpgrades()


func _on_loop_button_pressed() -> void:
	SceneTransition.Loop()


func _on_pause_menu_debug_mode(state: bool) -> void:
	debug_buttons.visible = state

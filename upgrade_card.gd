class_name UpgradeCard
extends MarginContainer

@onready var button: Button = %Button
@onready var upgrade_pic: TextureRect = %UpgradePic
@onready var upgrade_name: Label = %UpgradeName
@onready var upgrade_description: Label = %UpgradeDescription
@onready var nine_patch_rect: NinePatchRect = %NinePatchRect

@export var UpgradeData: UpgradeResource

signal chosen()
	
func setData(data: UpgradeResource): 
	UpgradeData = data
	if UpgradeData.image != null:
		upgrade_pic.texture = UpgradeData.image
	if UpgradeData.upgradeName != "": 
		upgrade_name.text = UpgradeData.upgradeName
	if UpgradeData.description != "":
		upgrade_description.text = UpgradeData.description

var inFocus: bool = false
var down: bool = false

func _on_focus_entered() -> void:
	inFocus = true
	if down: return
	nine_patch_rect.region_rect.position.y = 57

func _on_focus_exited() -> void:
	inFocus = false
	if down: return
	nine_patch_rect.region_rect.position.y = 9


func _on_button_button_down() -> void:
	down = true
	nine_patch_rect.region_rect.position.y = 105

func _on_button_button_up() -> void:
	if inFocus:
		chosen.emit()
		nine_patch_rect.region_rect.position.y = 57
	else: nine_patch_rect.region_rect.position.y = 9
	down = false
	

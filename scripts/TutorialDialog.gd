extends Control

onready var close_btn : Button = $Panel/VBoxContainer/Foot/CloseButton

func _ready():
	pass


func _on_CloseButton_pressed():
	hide()



func _on_NoMoreTipsCheckBox_toggled(button_pressed):
	Preferences.tutorial_popup = !button_pressed
	SaveSystem.save_preferences()

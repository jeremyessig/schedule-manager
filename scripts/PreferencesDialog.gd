extends Control

onready var card_index_top_checkbox : CheckBox = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox/CardIndexTop/CardIndexTopCheckBox


onready var right_panel : Control = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel
onready var lessons_box : VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox
onready var preferences_box : VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/PreferencesBox
onready var save_load_box : VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/SaveLoadBox

func _ready():
	Signals.connect("preferences_loaded", self, "refresh_GUI")


func refresh_GUI() -> void:
	card_index_top_checkbox.pressed = Preferences.card_index_top

func _hide_RightPanel_children() ->void:
	for vbox in right_panel.get_children():
		vbox.hide()

func _on_CloseBtn_pressed():
	SaveSystem.load_preferences()
	hide()


func _on_SaveAndCloseBtn_pressed():
	SaveSystem.save_preferences()
	hide()


func _on_CardIndexTopCheckBox_toggled(button_pressed):
	Preferences.set_card_index_top(button_pressed)


func _on_LessonsBtn_pressed():
	_hide_RightPanel_children()
	lessons_box.show()


func _on_PreferencesBtn_pressed():
	_hide_RightPanel_children()
	preferences_box.show()

func _on_SaveLoadBtn_pressed():
	_hide_RightPanel_children()
	save_load_box.show()

func _on_SetDefaultPreferencesBtn_pressed():
	SaveSystem.load_preferences("user://default_preferences.tres")
	SaveSystem.save_preferences()




func _on_AutoSaveCheckBox_toggled(button_pressed):
	Preferences.set_autosave(button_pressed)

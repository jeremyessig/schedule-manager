extends Control

var CM_time :Array = ["0", "00"]
var TD_time :Array = ["0", "00"]

var selected_tree_btn :StyleBoxFlat= preload("res://res/buttons/tree_button_selected_blue.tres")
var selected_tree_btn_hover:StyleBoxFlat = preload("res://res/buttons/tree_button_selected_hover_blue.tres")

onready var card_index_top_checkbox : CheckBox = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox/CardIndexTop/CardIndexTopCheckBox
onready var autosave_checkbox : CheckBox = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/SaveLoadBox/AutoSave/AutoSaveCheckBox
onready var autosave_wait_time_optionbutton : OptionButton = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/SaveLoadBox/AutoSaveWaitTime/AutoSaveWaitTimeOptionButton
onready var CM_default_time_hour_optionbutton : OptionButton = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox/CMDefaultTime/CMDefaultTimeHourOptionButton
onready var CM_default_time_minutes_optionbutton: OptionButton = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox/CMDefaultTime/CMDefaultTimeMinutesOptionButton
onready var TD_default_time_hour_optionbutton : OptionButton = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox/TDDefaultTime/TDDefaultTimeHourOptionButton
onready var TD_default_time_minutes_optionbutton: OptionButton = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox/TDDefaultTime/TDDefaultTimeMinutesOptionButton
onready var start_window_size_optionbutton : OptionButton = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/WindowBox/StartWindowSize/StartWindowSizeOptionButton

onready var right_panel : Control = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel
onready var lessons_box : VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/LessonsBox
onready var preferences_box : VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/PreferencesBox
onready var save_load_box : VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/SaveLoadBox
onready var window_box : VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/RightPanel/WindowBox

onready var tree_buttons_container: VBoxContainer = $Panel/VBoxContainer/Body/HBoxContainer/LeftPanel/TreeButtonsContainer
onready var lesson_btn : Button = $Panel/VBoxContainer/Body/HBoxContainer/LeftPanel/TreeButtonsContainer/LessonsBtn
onready var window_btn : Button = $Panel/VBoxContainer/Body/HBoxContainer/LeftPanel/TreeButtonsContainer/WindowBtn
onready var preferences_btn : Button = $Panel/VBoxContainer/Body/HBoxContainer/LeftPanel/TreeButtonsContainer/PreferencesBtn
onready var save_load_btn : Button = $Panel/VBoxContainer/Body/HBoxContainer/LeftPanel/TreeButtonsContainer/SaveLoadBtn


func _ready():
	SaveSystem.load_preferences()
	Signals.connect("preferences_loaded", self, "refresh_GUI")
	Signals.connect("preferences_shown", self, "refresh_GUI")
	Signals.connect("preferences_reseted", self, "reset_to_default")
	_hide_RightPanel_children()
	lessons_box.show()
	set_selected_tree_button(lesson_btn)
	refresh_GUI()
	

func set_selected_tree_button(button:Button) ->void:
	button.set("custom_styles/normal",selected_tree_btn)
	button.set("custom_styles/hover",selected_tree_btn_hover)
	button.set("custom_colors/font_color",Color("#FFFFFF"))
	button.set("custom_colors/font_color_hover",Color("#FFFFFF"))

func set_unselected_tree_button(button:Button) ->void:
	button.set("custom_styles/normal",StyleBoxEmpty.new())
	button.set("custom_styles/hover",StyleBoxEmpty.new())
	button.set("custom_colors/font_color",Color("#323232"))
	button.set("custom_colors/font_color_hover",Color("#4e4e4e"))

func set_tree_button(button:Button) ->void:
	for btn in tree_buttons_container.get_children():
		if btn == button:
			set_selected_tree_button(btn)
		else:
			set_unselected_tree_button(btn)
			

func reset_to_default() ->void:
	SaveSystem.load_preferences("user://default_preferences.tres")
	SaveSystem.save_preferences()


func refresh_GUI() -> void:
	card_index_top_checkbox.pressed = Preferences.card_index_top
	autosave_checkbox.pressed = Preferences.autosave
	set_lesson_duration_table()
	CM_default_time_hour_optionbutton.selected = Global.find_item_string(CM_default_time_hour_optionbutton, CM_time[0])
	CM_default_time_minutes_optionbutton.selected = Global.find_item_string(CM_default_time_minutes_optionbutton, CM_time[1])
	TD_default_time_hour_optionbutton.selected = Global.find_item_string(TD_default_time_hour_optionbutton, TD_time[0])
	TD_default_time_minutes_optionbutton.selected = Global.find_item_string(TD_default_time_minutes_optionbutton, TD_time[1])
	refresh_autosave_wait_time_optionbutton()
	refresh_start_window_size_optionbutton()


func refresh_autosave_wait_time_optionbutton():
	autosave_wait_time_optionbutton.disabled = !Preferences.autosave
	var minutes_str : String = str(Preferences.autosave_wait_time/60)
	autosave_wait_time_optionbutton.selected = Global.find_item_string(autosave_wait_time_optionbutton, minutes_str)
		

func set_lesson_duration_table() ->void:
	CM_time = Time.get_time_24h_StringArray(Preferences.CM_default_duration)
	TD_time = Time.get_time_24h_StringArray(Preferences.TD_default_duration)

func refresh_start_window_size_optionbutton() ->void:
	var size :String = str(Preferences.start_window_size.x) + "x" + str(Preferences.start_window_size.y)
	start_window_size_optionbutton.selected = Global.find_item_string(start_window_size_optionbutton, size)


func _hide_RightPanel_children() ->void:
	for vbox in right_panel.get_children():
		vbox.hide()

func _on_CloseBtn_pressed():
	SaveSystem.load_preferences()
	set_lesson_duration_table()
	hide()


func _on_SaveAndCloseBtn_pressed():
	SaveSystem.save_preferences()
	hide()


func _on_CardIndexTopCheckBox_toggled(button_pressed):
	Preferences.set_card_index_top(button_pressed)



##_________________ Boutons de navigation____________________

func _on_LessonsBtn_pressed():
	_hide_RightPanel_children()
	lessons_box.show()
	set_tree_button(lesson_btn)

func _on_PreferencesBtn_pressed():
	_hide_RightPanel_children()
	preferences_box.show()
	set_tree_button(preferences_btn)

func _on_SaveLoadBtn_pressed():
	_hide_RightPanel_children()
	save_load_box.show()
	set_tree_button(save_load_btn)

func _on_WindowBtn_pressed():
	_hide_RightPanel_children()
	window_box.show()
	set_tree_button(window_btn)
	

##________________________________________

func _on_SetDefaultPreferencesBtn_pressed():
	reset_to_default()



func _on_AutoSaveCheckBox_toggled(button_pressed):
	Preferences.set_autosave(button_pressed)
	refresh_autosave_wait_time_optionbutton()
	var minutes_string :String = Global.get_item_string(autosave_wait_time_optionbutton)
	Preferences.set_autosave_wait_time(int(minutes_string) * 60)



func _on_AutoSaveWaitTimeOptionButton_item_selected(index):
	var minutes_string :String= autosave_wait_time_optionbutton.get_item_text(index)
	Preferences.set_autosave_wait_time(int(minutes_string) * 60)



##______________________Definir la duree par defaut des cours_______________________

func _on_CMDefaultTimeHourOptionButton_item_selected(index):
	CM_time[0] = CM_default_time_hour_optionbutton.get_item_text(index)
	Preferences.CM_default_duration = Time.get_minutes(CM_time)


func _on_CMDefaultTimeMinutesOptionButton_item_selected(index):
	CM_time[1] = CM_default_time_minutes_optionbutton.get_item_text(index)
	Preferences.CM_default_duration = Time.get_minutes(CM_time)


func _on_TDDefaultTimeHourOptionButton_item_selected(index):
	TD_time[0] = TD_default_time_hour_optionbutton.get_item_text(index)
	Preferences.TD_default_duration = Time.get_minutes(TD_time)


func _on_TDDefaultTimeMinutesOptionButton_item_selected(index):
	TD_time[1] = TD_default_time_minutes_optionbutton.get_item_text(index)
	Preferences.TD_default_duration = Time.get_minutes(TD_time)



##_________________________ Preferences Box___________________________

func _on_OpenFileExplorerBtn_pressed():
	OS.shell_open(ProjectSettings.globalize_path("user://"))




##_________________________ Window Box_____________________________


func _on_StartWindowSizeOptionButton_item_selected(index):
	var size_table :Array = start_window_size_optionbutton.get_item_text(index).split("x")
	Preferences.start_window_size = Vector2(int(size_table[0]), int(size_table[1]))

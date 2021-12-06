## Herite de la scene LessonDialog et de son script LessonDialog.gd

extends "res://scripts/LessonDialog.gd"

var is_lesson_creating: bool = false

func _ready():
	Global.alert_dialog.connect("confirmed", self, "_confirmed_error")
	Global.alert_dialog.connect("canceled", self, "_canceled_error")


func _confirmed_error(error) ->void:
	match error:
		"RoomNotFound":
			print(is_lesson_creating)
			if is_lesson_creating == false:
				return
			create_lesson()

func _canceled_error(error) ->void:
	match error:
		"RoomNotFound":
			is_lesson_creating = false


func set_lesson_duration() ->void:
	var type = Global.get_item_string(type_option_button)
	var time_table : Array
	if type == "Cours Magistral":
		time_table = Time.get_time_24h_StringArray(Preferences.CM_default_duration)
	else:
		time_table = Time.get_time_24h_StringArray(Preferences.TD_default_duration)
	duration_hours_option_button.selected = Global.find_item_string(duration_hours_option_button, time_table[0])
	duration_minutes_option_button.selected = Global.find_item_string(duration_minutes_option_button, time_table[1])


#______________Initialisation de la creation du cours_____________
func create_lesson() ->void:
	print(is_lesson_creating)
	if is_lesson_creating == false:
		return 
	if not check_subject_lesson_database():
		return
	var datas = create_data_dictionary()
	datas["is_displayed"] = false
	Signals.emit_signal("lesson_created", datas) ## To LeftPanel by Signals
	is_lesson_creating = false



##________________Methodes connectees par signal_______________________________
func _on_CreateButton_pressed() -> void:
	is_lesson_creating = true
	if not check_for_validation():
		return
	create_lesson()


func _on_ColorGrid_color_picked(color):
	card_color = color
	update_color(card_color)


func _on_TypeOptionButton_item_selected(index):
	set_lesson_duration()

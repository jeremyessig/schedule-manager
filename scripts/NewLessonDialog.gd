## Herite de la scene LessonDialog et de son script LessonDialog.gd

extends "res://scripts/LessonDialog.gd"

var is_lesson_creating: bool = false

func _ready():
	Signals.connect("error_confirmed", self, "_on_error_confirmed")
	Signals.connect("error_canceled", self, "_on_canceled_error")
	Signals.connect("dialog_new_lesson_shown", self, "_shown")


func _shown() ->void:
	check_subject_lesson_database()
	reset_default_GUI()
	set_lesson_duration()
	_set_fields_messages_no_database_found()
	_use_same_color_as_CM()
	show()
		

func _on_error_confirmed(error, node_path) ->void:
	if get_path() != node_path:
		return
	match error:
		"RoomNotFound":
			print(is_lesson_creating)
			if is_lesson_creating == false:
				return
			create_lesson()

func _on_canceled_error(error, node_path) ->void:
	if get_path() != node_path:
		return
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


##_______________ GUI __________________________
func _set_fields_messages_no_database_found() ->void:
	if Global.subjects_database.empty():
		subject_option_button.text = "Aucune matière enregistrée"
	if Global.lessons_database.empty():
		lesson_option_button.text = "Aucun cours enregistré"
	if Global.locations_database.empty():
		location_option_button.text = "Aucun campus enregistré"


func _use_same_color_as_CM() ->void:
	if not Preferences.TD_is_same_color_as_CM:
		return
	if Global.get_item_string(type_option_button) != "Travaux Dirigés":
		return
	for card in get_tree().get_nodes_in_group("CM_lesson_cards"):
		if card.lesson == Global.get_item_string(lesson_option_button):
			update_color(card.color)


#______________Initialisation de la creation du cours_____________
func create_lesson() ->void:
	if is_lesson_creating == false:
		return 
	if not check_subject_lesson_database():
		return
	var datas = create_data_dictionary()
	datas["is_displayed"] = false
	Signals.emit_signal("lesson_created", datas) ## To LeftPanel by Signals
	is_lesson_creating = false
	set_color_same_as_CM(datas["color"], datas["lesson"])



##________________Methodes connectees par signal_______________________________
func _on_CreateButton_pressed() -> void:
	is_lesson_creating = true
	if not check_for_validation(get_path()):
		return
	create_lesson()


func _on_ColorGrid_color_picked(color):
	card_color = color
	update_color(card_color)


func _on_TypeOptionButton_item_selected(index):
	set_lesson_duration()
	_use_same_color_as_CM()


func _on_LessonOptionButton_item_selected(index):
	_use_same_color_as_CM()


func _on_SubjectOptionButton_selected(index):
	_use_same_color_as_CM()

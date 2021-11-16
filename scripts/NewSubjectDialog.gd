## Les cours sont obligatoirement lies a une matiere. Lorsqu'une matiere est supprimee, tous ses cours sont supprime avec elle.
## Les matieres sont stockees dans un Array (global.gd)
## Les cours sont stockes dans un dictionnaire avec pour clef le nom du cours et 
## un tableau en valeur contenant le nom du cours (index [0]) et la matiere (index [1])

extends Control

var default_blue_btn_normal : StyleBoxFlat = preload("res://res/buttons/default_blue_button_normal.tres")
var default_blue_btn_focus : StyleBoxFlat = preload("res://res/buttons/default_blue_button_focus.tres")
var default_blue_btn_hover : StyleBoxFlat = preload("res://res/buttons/default_blue_button_hover.tres")


onready var add_subject_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/SubjectGrid/AddSubjectLineEdit
onready var notification : Label = $Panel/VBoxContainer/Body/VBoxContainer/Notification
onready var remove_subject_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/SubjectGrid/RemoveSubjectOptionButton
onready var add_lesson_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/LessonGrid/AddLessonLineEdit
onready var remove_lesson_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/LessonGrid/RemoveLessonOptionButton
onready var define_lesson_subject_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/LessonGrid/DefineLessonSubjectOptionButton
onready var add_location_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/LocationGrid/AddLocationLineEdit
onready var remove_location_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/LocationGrid/RemoveLocationOptionButton
onready var subject_grid : GridContainer = $Panel/VBoxContainer/Body/VBoxContainer/SubjectGrid
onready var lesson_grid : GridContainer = $Panel/VBoxContainer/Body/VBoxContainer/LessonGrid
onready var location_grid : GridContainer = $Panel/VBoxContainer/Body/VBoxContainer/LocationGrid
onready var subject_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer/SubjectBtn
onready var lesson_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer/LessonBtn
onready var location_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer/LocationBtn
onready var animation : AnimationPlayer = $AnimationPlayer
onready var body_vbox : VBoxContainer = $Panel/VBoxContainer/Body/VBoxContainer
onready var buttons_container : HBoxContainer = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer



func _ready():
	Signals.connect("database_reseted", self, "_on_database_reseted")
	Signals.connect("lessons_database_updated", self, "_refresh_lessons_GUI")
	Signals.connect("locations_database_updated", self, "_refresh_locations_GUI")
	Signals.connect("subjects_database_updated", self, "_update_GUI")
	_btn_focused(subject_btn)


##________________________ Methodes de gestion des donees____________
func _add_subject_to_database(subject:String) ->void:
	if add_subject_line_edit.text == "":
		_error_notification("Veuillez entrer une valeur correcte.")
	if Global.subjects_database.has(add_subject_line_edit.text):
		_error_notification("Cette matière est déjà enregistrée.")
	Global.add_to_subjects_database(subject)


func _add_location_to_database(location:String) ->void:
	if add_location_line_edit.text == "":
		_error_notification("Veuillez entrer une valeur correcte.")
	if Global.locations_database.has(add_location_line_edit.text):
		_error_notification("Cet établissement est déjà enregistré.")
	Global.add_to_locations_database(location)
	
	
func _add_lesson_to_database(lesson:String, subject:String) ->void:
	if add_lesson_line_edit.text == "":
		_error_notification("Veuillez entrer une valeur correcte.")
	if Global.subjects_database == []:
		_error_notification("Veuillez spécifier la matière de la leçon")
	if Global.lessons_database.has(add_lesson_line_edit.text):
		_error_notification("Cette leçon est déjà enregistrée.")
	Global.add_to_lessons_database(lesson, [lesson, subject])
	animation.play("lesson_saved")


func _remove_lesson_from_database() ->void:
	var lesson_title: String = Global.get_item_string(remove_lesson_option_button)
	Global.remove_from_lessons_database(lesson_title)
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		if lesson_card.lesson == lesson_title:
			lesson_card.delete()


func _remove_subject_from_database() ->void:
	var subject:String = Global.get_item_string(remove_subject_option_button)
	Global.remove_from_subjects_database(subject)
	var tmp:Dictionary = {}
	for k in Global.lessons_database:
		if Global.lessons_database[k][1] != subject:
			tmp[k] = Global.lessons_database[k]
	Global.set_lessons_database(tmp)
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		if !Global.lessons_database.has(lesson_card.lesson):
			lesson_card.delete()


func _remove_location_from_database() ->void:
	var location_title: String = Global.get_item_string(remove_location_option_button)
	Global.remove_from_locations_database(location_title)
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		if location_title == lesson_card["location"]:
			lesson_card.delete()
	


##_________________________ Gestion de la GUI _________________________
func _update_GUI() ->void:
	Global.update_option_button(remove_subject_option_button, Global.subjects_database)
	Global.update_option_button(remove_lesson_option_button, Global.lessons_database)
	Global.update_option_button(define_lesson_subject_option_button, Global.subjects_database)
	
func _refresh_lessons_GUI() ->void:
	Global.update_option_button(remove_lesson_option_button, Global.lessons_database)

func _refresh_locations_GUI() ->void:
	Global.update_option_button(remove_location_option_button, Global.locations_database)

func _error_notification(msg:String) ->void:
	notification.add_color_override("font_color", Color("#a50000"))
	notification.text = msg
	return


func _show_grid(grid:GridContainer) ->void:
	for node in body_vbox.get_children():
		if node is GridContainer:
			node.hide()
	grid.show()


func _btn_focused(button:Button) ->void:
	for btn in buttons_container.get_children():
		btn.set("custom_styles/normal",default_blue_btn_normal)
		btn.set("custom_styles/hover",default_blue_btn_hover)
	button.set("custom_styles/normal",default_blue_btn_focus)
	button.set("custom_styles/hover",default_blue_btn_focus)


##_________________________ Methodes connectees ___________________________________
func _on_database_reseted(database_name:String) -> void:
	if database_name == "subjects_database" or database_name == "lessons_database" :
		_update_GUI()
	if database_name == "locations_database":
		_refresh_locations_GUI()


func _on_CancelButton_pressed() -> void:
	notification.text = ""
	hide()


func _on_CreateButton_pressed() -> void:
	_add_subject_to_database(add_subject_line_edit.text)
	add_subject_line_edit.text = ""
	

func _on_RemoveSubjectButton_pressed() -> void:
	_remove_subject_from_database()


func _on_CreateLessonButton_pressed() -> void:
	var subject = Global.get_item_string(define_lesson_subject_option_button)
	_add_lesson_to_database(add_lesson_line_edit.text, subject)
	add_lesson_line_edit.text = ""


func _on_RemoveLessonButton_pressed() -> void:
	_remove_lesson_from_database()


func _on_AddSubjectLineEdit_text_entered(new_text):
	_add_subject_to_database(new_text)
	add_subject_line_edit.text = ""


func _on_AddLessonLineEdit_text_entered(new_text):
	var subject = Global.get_item_string(define_lesson_subject_option_button)
	_add_lesson_to_database(new_text, subject)
	add_lesson_line_edit.text = ""


func _on_AddLocationButton_pressed():
	_add_location_to_database(add_location_line_edit.text)
	add_location_line_edit.text = ""
	print(Global.locations_database)


func _on_AddLocationLineEdit_text_entered(new_text):
	_add_location_to_database(new_text)
	add_location_line_edit.text = ""


func _on_RemoveLocationButton_pressed():
	_remove_location_from_database()


## Boutons de navigation entre les sujets, les cours et les etablissements
	


func _on_SubjectBtn_pressed():
	_show_grid(subject_grid)
	_btn_focused(subject_btn)


func _on_LessonBtn_pressed():
	_show_grid(lesson_grid)
	_btn_focused(lesson_btn)


func _on_LocationBtn_pressed():
	_show_grid(location_grid)
	_btn_focused(location_btn)

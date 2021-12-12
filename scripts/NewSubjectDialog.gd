## Les cours sont obligatoirement lies a une matiere. Lorsqu'une matiere est supprimee, tous ses cours sont supprime avec elle.
## Les matieres sont stockees dans un Array (global.gd)
## Les cours sont stockes dans un dictionnaire avec pour clef le nom du cours et 
## un tableau en valeur contenant le nom du cours (index [0]) et la matiere (index [1])

extends Control

var default_blue_btn_normal : StyleBoxFlat = preload("res://res/buttons/default_blue_button_normal.tres")
var default_blue_btn_focus : StyleBoxFlat = preload("res://res/buttons/default_blue_button_focus.tres")
var default_blue_btn_hover : StyleBoxFlat = preload("res://res/buttons/default_blue_button_hover.tres")

var default_remove_subject_message : String 
var default_remove_lesson_message : String
var default_remove_location_message : String

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
onready var discipline_grid : GridContainer = $Panel/VBoxContainer/Body/VBoxContainer/DisciplineGrid
onready var subject_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer/SubjectBtn
onready var lesson_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer/LessonBtn
onready var location_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer/LocationBtn
onready var discipline_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer/DisciplineBtn
onready var description_label : Label = $Panel/VBoxContainer/Body/VBoxContainer/Description
onready var notification_player : AnimationPlayer = $NotificationPlayer
onready var body_vbox : VBoxContainer = $Panel/VBoxContainer/Body/VBoxContainer
onready var buttons_container : HBoxContainer = $Panel/VBoxContainer/Body/VBoxContainer/ButtonsContainer
onready var remove_subject_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/SubjectGrid/RemoveSubjectButton
onready var remove_lesson_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/LessonGrid/RemoveLessonButton
onready var remove_location_btn : Button = $Panel/VBoxContainer/Body/VBoxContainer/LocationGrid/RemoveLocationButton



func _ready():
	Signals.connect("database_reseted", self, "_on_database_reseted")
	Signals.connect("lessons_database_updated", self, "_refresh_lessons_GUI")
	Signals.connect("locations_database_updated", self, "_refresh_locations_GUI")
	Signals.connect("subjects_database_updated", self, "_update_GUI")
	Signals.connect("error_confirmed", self, "_on_error_confirmed")
	default_remove_subject_message = remove_subject_option_button.text
	default_remove_lesson_message = remove_lesson_option_button.text
	default_remove_location_message = remove_location_option_button.text
	_btn_focused(subject_btn)


##________________________ Methodes de gestion des donees____________
func _add_subject_to_database(subject:String) ->void:
	if add_subject_line_edit.text == "":
		notification_player.play("empty_field")
		return
	if Global.does_subejct_exist(add_subject_line_edit.text):
		notification_player.play("subject_exists")
		return
	Global.add_to_subjects_database(subject)
	notification_player.play("subject_saved")


func _add_location_to_database(location:String) ->void:
	if add_location_line_edit.text == "":
		notification_player.play("empty_field")
		return
	if Global.does_location_exist(add_location_line_edit.text):
		notification_player.play("location_exists")
		return
	Global.add_to_locations_database(location)
	notification_player.play("location_saved")
	
	
func _add_lesson_to_database(lesson:String, subject:String) ->void:
	if add_lesson_line_edit.text == "":
		notification_player.play("empty_field")
		return
	if Global.subjects_database == []:
		notification_player.play("lesson_without_subject")
		return
	if Global.does_lesson_exist(add_lesson_line_edit.text):
		notification_player.play("lesson_exists")
		return
	Global.add_to_lessons_database(lesson, [lesson, subject])
	notification_player.play("lesson_saved")


func _remove_lesson_from_database() ->void:
	if remove_lesson_option_button.get_item_count() == 0:
		notification_player.play("empty_field")
		return
	var lesson_title: String = Global.get_item_string(remove_lesson_option_button)
	Global.remove_from_lessons_database(lesson_title)
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		if lesson_card.lesson == lesson_title:
			lesson_card.delete()
	notification_player.play("element_deleted")


func _remove_subject_from_database() ->void:
	if remove_subject_option_button.get_item_count() == 0:
		notification_player.play("empty_field")
		return
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
	notification_player.play("element_deleted")


func _remove_location_from_database() ->void:
	if remove_location_option_button.get_item_count() == 0:
		notification_player.play("empty_field")
		return
	var location_title: String = Global.get_item_string(remove_location_option_button)
	Global.remove_from_locations_database(location_title)
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		if location_title == lesson_card["location"]:
			lesson_card.delete()
	notification_player.play("element_deleted")
	


##_________________________ Gestion de la GUI _________________________
func _update_GUI() ->void:
	_refresh_subjects_GUI()


func _refresh_subjects_GUI() ->void:
	Global.update_option_button(remove_subject_option_button, Global.subjects_database)
	_refresh_lessons_GUI()
	Global.update_option_button(define_lesson_subject_option_button, Global.subjects_database)
	if Global.subjects_database.empty():
		remove_subject_option_button.text = default_remove_subject_message
		define_lesson_subject_option_button.text = default_remove_lesson_message
	
	
func _refresh_lessons_GUI() ->void:
	Global.update_option_button(remove_lesson_option_button, Global.lessons_database)
	if Global.lessons_database.empty():
		remove_lesson_option_button.text = default_remove_lesson_message


func _refresh_locations_GUI() ->void:
	Global.update_option_button(remove_location_option_button, Global.locations_database)
	if Global.locations_database.empty():
		remove_location_option_button.text = default_remove_location_message


func _error_notification(msg:String) ->void:
	notification.add_color_override("font_color", Color("#a50000"))
	notification.text = msg


func _show_grid(grid:GridContainer) ->void:
	for node in body_vbox.get_children():
		if node is GridContainer:
			node.hide()
	grid.show()


func _set_button_navigation_selected(button:Button) ->void:
	button.set("custom_styles/normal",default_blue_btn_focus)
	button.set("custom_styles/hover",default_blue_btn_focus)
	button.set("custom_styles/focus",default_blue_btn_focus)
	button.set("custom_styles/pressed",default_blue_btn_focus)

func _set_button_navigation_unselected(button:Button) ->void:
	button.set("custom_styles/normal",default_blue_btn_normal)
	button.set("custom_styles/hover",default_blue_btn_hover)
	button.set("custom_styles/focus",default_blue_btn_normal)
	button.set("custom_styles/pressed",default_blue_btn_focus)

func _btn_focused(button:Button) ->void:
	for btn in buttons_container.get_children():
		if btn == button:
			_set_button_navigation_selected(btn)
		else:
			_set_button_navigation_unselected(btn)


##_________________________ Methodes connectees ___________________________________
func _on_error_confirmed(error, node_path) ->void:
	if remove_subject_btn.get_path() == node_path and error == "ConfirmAllDeletion":
		_remove_subject_from_database()
		return
	if remove_lesson_btn.get_path() == node_path and error == "ConfirmAllDeletion":
		_remove_lesson_from_database()
		return
	if remove_location_btn.get_path() == node_path and error == "ConfirmAllDeletion":
		_remove_location_from_database()
		return
		

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
	Signals.emit_signal("error_emitted", "ConfirmAllDeletion", remove_subject_btn.get_path())
#	_remove_subject_from_database()


func _on_CreateLessonButton_pressed() -> void:
	var subject = Global.get_item_string(define_lesson_subject_option_button)
	_add_lesson_to_database(add_lesson_line_edit.text, subject)
	add_lesson_line_edit.text = ""


func _on_RemoveLessonButton_pressed() -> void:
	Signals.emit_signal("error_emitted", "ConfirmAllDeletion", remove_lesson_btn.get_path())
#	_remove_lesson_from_database()


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


func _on_AddLocationLineEdit_text_entered(new_text):
	_add_location_to_database(new_text)
	add_location_line_edit.text = ""


func _on_RemoveLocationButton_pressed():
	Signals.emit_signal("error_emitted", "ConfirmAllDeletion", remove_location_btn.get_path())
#	_remove_location_from_database()


## Boutons de navigation entre les sujets, les cours et les etablissements
	

func _on_SubjectBtn_pressed():
	_show_grid(subject_grid)
	_btn_focused(subject_btn)
	description_label.text = "Les cours ont besoins d'être rattachés à une matière d'étude."


func _on_LessonBtn_pressed():
	_show_grid(lesson_grid)
	_btn_focused(lesson_btn)
	description_label.text = 'Vous devez définir les titres de vos cours en les ajoutants ici. Vous pourrez ensuite créer un cours en cliquant sur le bouton "Créer un cours"'

func _on_LocationBtn_pressed():
	_show_grid(location_grid)
	_btn_focused(location_btn)
	description_label.text = "Entrez les différents lieux où vous étudiez. Si vous avez plusieurs lieux d'étude, vous pourrez définir des temps de trajet dans les paramtères."


func _on_DisciplineBtn_pressed():
	_show_grid(discipline_grid)
	_btn_focused(discipline_btn)

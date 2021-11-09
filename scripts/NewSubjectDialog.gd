## Les cours sont obligatoirement lies a une matiere. Lorsqu'une matiere est supprimee, tous ses cours sont supprime avec elle.
## Les matieres sont stockees dans un Array (global.gd)
## Les cours sont stockes dans un dictionnaire avec pour clef le nom du cours et 
## un tableau en valeur contenant le nom du cours (index [0]) et la matiere (index [1])

extends Control


onready var add_subject_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/AddSubjectLineEdit
onready var notification : Label = $Panel/VBoxContainer/Body/VBoxContainer/Notification
onready var remove_subject_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/RemoveSubjectOptionButton
onready var add_lesson_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/AddLessonLineEdit
onready var remove_lesson_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/RemoveLessonOptionButton
onready var define_lesson_subject_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/DefineLessonSubjectOptionButton



##________________________ Methodes de gestion des donees____________
func _add_subject_to_database(subject:String) ->void:
	if add_subject_line_edit.text == "":
		notification.add_color_override("font_color", Color("#a50000"))
		notification.text = "Veuillez entrer une valeur correcte."
		return	
	if Global.subjects_database.has(add_subject_line_edit.text):
		notification.add_color_override("font_color", Color("#a50000"))
		notification.text = "Cette matière est déjà enregistrée."
		return
	Global.subjects_database.append(subject)
	Global.update_option_button(remove_subject_option_button, Global.subjects_database)
	Global.update_option_button(define_lesson_subject_option_button, Global.subjects_database)
	Signals.emit_signal("subject_added") # to NewLessonDialog by Signals
	
	
func _add_lesson_to_database(lesson:String, subject:String) ->void:
	if add_lesson_line_edit.text == "":
		notification.add_color_override("font_color", Color("#a50000"))
		notification.text = "Veuillez entrer une valeur correcte."
		return	
	if Global.subjects_database == []:
		notification.add_color_override("font_color", Color("#a50000"))
		notification.text = "Veuillez spécifier la matière de la leçon"
		return
	if Global.lessons_database.has(add_lesson_line_edit.text):
		notification.add_color_override("font_color", Color("#a50000"))
		notification.text = "Cette leçon est déjà enregistrée."
		return
	Global.lessons_database[lesson] = [lesson, subject]
	Signals.emit_signal("lesson_added") # to NewLessonDialog by Signals
	Global.update_option_button(remove_lesson_option_button, Global.lessons_database)
	print_debug(Global.lessons_database)


func _remove_lesson_from_database() ->void:
	var lesson_title: String = Global.get_item_string(remove_lesson_option_button)
	Global.lessons_database.erase(lesson_title)
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		if lesson_card.lesson == lesson_title:
			lesson_card.delete()
	Signals.emit_signal("lesson_added")
	_update_GUI()


func _remove_subject_from_database() ->void:
	var subject:String = Global.get_item_string(remove_subject_option_button)
	var i = Global.subjects_database.find(subject)
	Global.subjects_database.remove(i)
	var tmp:Dictionary = {}
	for k in Global.lessons_database:
		if Global.lessons_database[k][1] != subject:
			tmp[k] = Global.lessons_database[k]
	Global.lessons_database = tmp
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		if !Global.lessons_database.has(lesson_card.lesson):
			lesson_card.delete()
	Signals.emit_signal("subject_added")
	_update_GUI()	


##_________________________ Gestion de la GUI _________________________
func _update_GUI() ->void:
	Global.update_option_button(remove_subject_option_button, Global.subjects_database)
	Global.update_option_button(remove_lesson_option_button, Global.lessons_database)
	Global.update_option_button(define_lesson_subject_option_button, Global.subjects_database)



##_________________________ Methodes connectees ___________________________________
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

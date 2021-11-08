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
	
	


func _on_CancelButton_pressed() -> void:
	notification.text = ""
	hide()


func _on_CreateButton_pressed() -> void:
	var subject : String = add_subject_line_edit.text
	_add_subject_to_database(subject)
	add_subject_line_edit.text = ""
	

func _on_RemoveSubjectButton_pressed() -> void:
	var string = Global.get_item_string(remove_subject_option_button)
	var i = Global.subjects_database.find(string)
	Global.subjects_database.remove(i)
	for k in Global.lessons_database:
		if Global.lessons_database[k][1] == string:
			Global.lessons_database.erase(k)
	Global.update_option_button(remove_lesson_option_button, Global.lessons_database)
	Global.update_option_button(remove_subject_option_button, Global.subjects_database)
	Global.update_option_button(define_lesson_subject_option_button, Global.subjects_database)
	emit_signal("subject_added")


func _on_CreateLessonButton_pressed() -> void:
	var subject = Global.get_item_string(define_lesson_subject_option_button)
	_add_lesson_to_database(add_lesson_line_edit.text, subject)
	add_lesson_line_edit.text = ""


func _on_RemoveLessonButton_pressed() -> void:
	var string = Global.get_item_string(remove_lesson_option_button)
	Global.lessons_database.erase(string)
	emit_signal("lesson_added")
	print_debug(Global.lessons_database)

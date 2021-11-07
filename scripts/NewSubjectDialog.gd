extends Control


onready var add_subject_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/AddSubjectLineEdit
onready var notification : Label = $Panel/VBoxContainer/Body/VBoxContainer/Notification
onready var remove_subject_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/RemoveSubjectOptionButton
onready var add_lesson_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/AddLessonLineEdit
onready var remove_lesson_option_button : OptionButton = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/RemoveLessonOptionButton


func _add_string_to_database(line_edit: LineEdit, database: Array, category: String ) -> void:
	if line_edit.text == "":
		notification.add_color_override("font_color", Color("#a50000"))
		notification.text = "Veuillez entrer une valeur correcte."
		return
	if database.has(line_edit.text):
		notification.add_color_override("font_color", Color("#a50000"))
		notification.text = "Cette matière est déjà enregistrée."
		return
	database.append(line_edit.text)
	notification.add_color_override("font_color", Color("#00740f"))
	notification.text = "Nouvelle matière correctement ajoutée."
	line_edit.text = ""
	if category == "subject":
		Signals.emit_signal("subject_added") # to NewLessonDialog by Signals
		Global.update_option_button(remove_subject_option_button, Global.subjects_database)
	if category == "lesson":
		Signals.emit_signal("lesson_added") # to NewLessonDialog by Signals
		Global.update_option_button(remove_lesson_option_button, Global.lessons_database)






func _on_CancelButton_pressed() -> void:
	notification.text = ""
	hide()

func _on_CreateButton_pressed() -> void:
	_add_string_to_database(add_subject_line_edit, Global.subjects_database, "subject")
	

func _on_RemoveSubjectButton_pressed() -> void:
	var string = Global.get_item_string(remove_subject_option_button)
	var i = Global.subjects_database.find(string)
	Global.subjects_database.remove(i)
	Global.update_option_button(remove_subject_option_button, Global.subjects_database)
	emit_signal("subject_added")


func _on_CreateLessonButton_pressed() -> void:
	_add_string_to_database(add_lesson_line_edit, Global.lessons_database, "lesson")


func _on_RemoveLessonButton_pressed() -> void:
	var string = Global.get_item_string(remove_lesson_option_button)
	var i = Global.lessons_database.find(string)
	Global.lessons_database.remove(i)
	Global.update_option_button(remove_lesson_option_button, Global.lessons_database)
	emit_signal("lesson_added")

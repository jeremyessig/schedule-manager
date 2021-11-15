## Herite de la scene LessonDialog et de son script LessonDialog.gd

extends "res://scripts/LessonDialog.gd"



func _ready():
#	Global.new_lesson_button.connect("pressed", self, "_show_lesson_dialog")
	Global.alert_dialog.connect("confirmed", self, "_cancel_error")


func _cancel_error(error) ->void:
	match error:
		"RoomNotFound":
			create_lesson()



#______________Initialisation de la creation du cours_____________
func create_lesson() ->void:
	if not check_subject_lesson_database():
		return
	var datas = create_data_dictionary()
	datas["is_displayed"] = false
	Signals.emit_signal("lesson_created", datas) ## To LeftPanel by Signals



##________________Methodes connectees par signal_______________________________
func _on_CreateButton_pressed() -> void:
	if not check_for_validation():
		return
	create_lesson()


##_______________Methodes connectees______________________________
func _show_lesson_dialog() ->void: #From NewLessonButton by Main
	show()


func _on_ColorGrid_color_picked(color):
	card_color = color
	update_color(card_color)

## Herite de la scene LessonDialog et de son script LessonDialog.gd
## Les modifications des cartes se font directement via l'acces a celles-ci 
## grace a leur nodepath. 
extends "res://scripts/LessonDialog.gd"


var lesson_card : Node
var old_id : String
var data : Dictionary

onready var add_lesson_to_calendar_button :Button = $Panel/VBoxContainer/Foot/HBoxContainer/AddLessonToCalendarButton
onready var sub_lesson_to_calendar_button : Button = $Panel/VBoxContainer/Foot/HBoxContainer/SubLessonToCalendarButton

func _ready() -> void:
	Signals.connect("lesson_card_pressed", self, "_open_dialog") ## -> LessonCard -> Signals -> self



## Recherche dans OptionButton l'index correspondant a la phrase en parametre
func get_item_index_by_string(node:OptionButton, content:String) -> int:
	for item in node.get_item_count(): 
		if node.get_item_text(item) == content:
			return node.get_item_index(item)
	return 0

##_______________Affiche les informations de la card_lesson______________________
func _open_dialog(nodepath:NodePath) ->void:
	_show_edit_lesson_dialog()
	lesson_card = get_node(nodepath)
	_update_infos()
	update_color(card_color)


func _update_infos() ->void:
	title.text = lesson_card.lesson
	type_option_button.select(get_item_index_by_string(type_option_button, lesson_card.type))
	teacher_line_edit.text = lesson_card.teacher
	subject_option_button.select(get_item_index_by_string(subject_option_button, lesson_card.subject))
	lesson_option_button.select(get_item_index_by_string(lesson_option_button, lesson_card.lesson))
	room_line_edit.text = lesson_card.room
	duration_hours_option_button.select(get_item_index_by_string(duration_hours_option_button, lesson_card.duration[0]))
	duration_minutes_option_button.select(get_item_index_by_string(duration_minutes_option_button, lesson_card.duration[1]))
	schedule_days_option_button.select(get_item_index_by_string(schedule_days_option_button, lesson_card.schedule[1]))
	schedule_hours_option_button.select(get_item_index_by_string(schedule_hours_option_button, lesson_card.schedule[2]))
	schedule_minutes_option_button.select(get_item_index_by_string(schedule_minutes_option_button, lesson_card.schedule[3]))
	if lesson_card.is_obligatory:
		obligatory_check_button.pressed = true
	else:
		obligatory_check_button.pressed = false
	lesson_code_line_edit.text = lesson_card.lesson_code
	old_id = lesson_card.id
	card_color = lesson_card.color
	if lesson_card.is_displayed:
		add_lesson_to_calendar_button.hide()
		sub_lesson_to_calendar_button.show()
	else:
		add_lesson_to_calendar_button.show()
		sub_lesson_to_calendar_button.hide()




##_______________Edition du cours___________________________

func edit_lesson() ->void:
	var data :Dictionary = create_data_dictionary()
	data["color"] = card_color
	data["is_displayed"] = lesson_card.is_displayed
	Signals.emit_signal("lesson_edited", data, old_id)
	


##____________Fonctions connectees par signaux_______________________

func _show_edit_lesson_dialog() ->void:
	show()


func _on_DeleteButton_pressed():
	Signals.emit_signal("lesson_from_calendar_deleted", lesson_card.position, lesson_card.size, lesson_card.id)
	Signals.emit_signal("lesson_card_deleted", lesson_card.id)
	hide()


func _on_EditButton_pressed():
	var old := {"position":lesson_card.position, "size":lesson_card.size}
	edit_lesson()
	if lesson_card.is_displayed: ## Lorsque l'horaire est modifie, recharge la cellule dans le bon emplacement
		if old["position"].x != lesson_card.position.x or old["position"].y != lesson_card.position.y or lesson_card.size != old["size"]:
			Signals.emit_signal("lesson_from_calendar_deleted", old["position"], old["size"], lesson_card.id)
			yield(get_tree(),"idle_frame")
			var node_path = lesson_card.get_path()
			Global.calendar_array.add_lesson(node_path)
	hide()


func _on_ColorGrid_color_picked(color):
	card_color = color
	update_color(card_color)


func _on_DisplayedCheckButton_pressed():
	pass # Replace with function body.


func _on_AddLessonToCalendarButton_pressed():
	var node_path = lesson_card.get_path()
	Global.calendar_array.add_lesson(node_path)
	hide()


func _on_SubLessonToCalendarButton_pressed():
	if lesson_card.is_obligatory:
		var node_path := lesson_card.get_path()
		Signals.emit_signal("error_emitted", "ObligatoryLesson", node_path) # -> Signals -> AlertDialog 
	else:
		Signals.emit_signal("lesson_from_calendar_deleted", lesson_card.position, lesson_card.size, lesson_card.id)
	hide()

extends Control

signal confirmed(error)
signal canceled(error)

var error: String
var node : Node

onready var body := $Panel/VBoxContainer/Body
onready var confirm_button : Button = $Panel/VBoxContainer/Foot/ButtonsContainer/ConfirmButton
onready var sub_button : Button = $Panel/VBoxContainer/Foot/ButtonsContainer/SubButton
onready var room_not_found_label : Label = $Panel/VBoxContainer/Body/RoomNotFound
onready var lesson_already_in_calendar : Label = $Panel/VBoxContainer/Body/LessonAlreadyInCalendar
onready var filled_cell : Label = $Panel/VBoxContainer/Body/FilledCell
onready var lesson_obligatory : Label = $Panel/VBoxContainer/Body/LessonObligatory
onready var buttons_container := $Panel/VBoxContainer/Foot/ButtonsContainer
onready var cancel_button : Button = $Panel/VBoxContainer/Foot/ButtonsContainer/CancelButton
onready var loading_wrong_format : Label = $Panel/VBoxContainer/Body/LoadingWrongFormat
onready var saving_wrong_format : Label = $Panel/VBoxContainer/Body/SavingWrongFormat
onready var old_version : Label = $Panel/VBoxContainer/Body/OldVersion
onready var loading_old_save : Label = $Panel/VBoxContainer/Body/LoadingOldSave


func _ready():
	Signals.connect("error_emitted", self, "_show_alert_dialog")
	cancel_button.hide()
	confirm_button.hide()
	sub_button.hide()


func _show_alert_dialog(message, node_path) ->void:
	show()
	if node_path != null:
		node = get_node(node_path)
	match message:
		"RoomNotFound":
			confirm_button.show()
			cancel_button.show()
			room_not_found_label.show()
			error = message
			
		"LessonAlreadyInCalendar": ## Pas sur que cette erreur existe encore dans le code !
			sub_button.show()
			cancel_button.show()
			lesson_already_in_calendar.show()
			
		"FilledCell":
			filled_cell.show()
			cancel_button.show()
			
		"ObligatoryLesson":
			sub_button.show()
			cancel_button.show()
			lesson_obligatory.show()	
		
		"LoadingWrongFormat":
			cancel_button.show()
			loading_wrong_format.show()
			
		"SavingWrongFormat":
			cancel_button.show()
			saving_wrong_format.show()
		
		"OldVersion":
			cancel_button.show()
			old_version.show()
			
		"LoadingOldSave":
			cancel_button.show()
			loading_old_save.show()



func _clear_panel()->void:
	for child in body.get_children():
		child.hide()
	for child in buttons_container.get_children():
		child.hide()
	hide()


func _on_CancelButton_pressed() -> void:
	_clear_panel()


func _on_ConfirmButton_pressed():
	emit_signal("confirmed", error)
	_clear_panel()
	hide()


func _on_SubButton_pressed():
	Signals.emit_signal("lesson_from_calendar_deleted", node.position, node.size, node.id)
	_clear_panel()
	hide()

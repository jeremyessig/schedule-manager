extends Control


var subjects_and_lessons_are_ready := false
var card_color : String = "#1e90ff"

onready var type_option_button : OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/TypeOptionButton
onready var subject_option_button : OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/SubjectOptionButton
onready var lesson_option_button : OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/LessonOptionButton
onready var room_line_edit : LineEdit = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/RoomLineEdit
onready var duration_hours_option_button: OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/LessonDuration/HoursOptionButton
onready var duration_minutes_option_button: OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/LessonDuration/MinutesOptionButton
onready var notification : Label = $Panel/VBoxContainer/Body/VboxContainer/Notification
onready var schedule_days_option_button : OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/Schedule/DaysOptionButton
onready var schedule_hours_option_button : OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/Schedule/HoursOptionButton
onready var schedule_minutes_option_button : OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/Schedule/MinutesOptionButton
onready var teacher_line_edit : LineEdit = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/TeacherLineEdit
onready var lesson_code_line_edit : LineEdit = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/LessonCodeLineEdit
onready var obligatory_check_button : CheckButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/ObligatoryCheckButton
onready var title : Label = $Panel/VBoxContainer/Head/Title
onready var head_panel : Panel = $Panel/VBoxContainer/Head
onready var panel : Panel = $Panel
onready var vbox_container := $Panel/VBoxContainer/Body/VboxContainer





func _ready() -> void:
	Signals.connect("lesson_added", self, "_on_lesson_added")
	Signals.connect("subject_added", self,"_on_subject_added")


func _physics_process(delta):
	if  self.rect_size.y >= 820:
		panel.rect_size.y = 720
		vbox_container.rect_size.y = 580
		return
	panel.rect_size.y = 680
	vbox_container.rect_size.y = 543
	


##_______________Mise à jours des matieres et cours dans les bases de données____________________________
func _on_subject_added() ->void: ## From NewSubjectDialog and SaveSystem.gd by Signals
	Global.update_option_button(subject_option_button, Global.subjects_database)
	_check_subject_lesson_database()



func _on_lesson_added() ->void: ## From NewSubjectDialog and SaveSystem.gd by Signals
	Global.update_option_button(lesson_option_button, Global.lessons_database)
	_check_subject_lesson_database()


##______________Verifications avant validation du cours________________________
func _check_subject_lesson_database() ->bool:
	if Global.subjects_database.empty() or Global.lessons_database.empty():
		notification.text = ""
		return false
	notification.text = ""
	return true


func _check_lesson_duration() ->bool:
	if Global.get_item_string(duration_hours_option_button) == "0" and Global.get_item_string(duration_minutes_option_button) == "00":
		notification.text = "Vous devez indiquer un durée de cours valide!"
		return false
	notification.text = ""
	return true


func check_for_validation() :
	if not _check_subject_lesson_database():
		return false
	if not _check_lesson_duration():
		return false
	if _check_if_lesson_exist(lesson_option_button, type_option_button, schedule_days_option_button, schedule_hours_option_button, schedule_minutes_option_button, room_line_edit):
		notification.text = "Ce cours existe déjà !"
		return false
	if room_line_edit.text == "":
		notification.text = ""
		Signals.emit_signal("error_emitted", "RoomNotFound", null) ## To AlertDialog by Main
		return false
	return true



func _check_if_lesson_exist(lesson_arg: OptionButton, type_arg: OptionButton, day_arg:OptionButton, hours_arg:OptionButton, minutes_arg:OptionButton, room_arg:LineEdit):
	var card_id :String = lesson_arg.text + type_arg.text + day_arg.text + hours_arg.text + minutes_arg.text + room_arg.text
	card_id = card_id.replace(" ", "")
	card_id = card_id.replace("'", "")
	if Global.left_panel.does_lesson_exist(card_id, type_arg.text):
		return true
	return false


##_______________Creation et envoie des donnees par signal________________________

func create_data_dictionary() -> Dictionary:
	var type = Global.get_item_string(type_option_button)
	var subject = Global.get_item_string(subject_option_button)
	var lesson = Global.get_item_string(lesson_option_button)
	var duration: Array = [Global.get_item_string(duration_hours_option_button), Global.get_item_string(duration_minutes_option_button)]
	var teacher = teacher_line_edit.text
	var lesson_code = lesson_code_line_edit.text
	var room = room_line_edit.text
	var obligatory = obligatory_check_button.is_pressed()
	var color = card_color
	var schedule = [schedule_days_option_button.get_selected_id(), 
		Global.get_item_string(schedule_days_option_button), 
		Global.get_item_string(schedule_hours_option_button), 
		Global.get_item_string(schedule_minutes_option_button)]
	var card_id :String = lesson + type + schedule[1] + schedule[2] + schedule[3] + room
	card_id = card_id.replace(" ", "")
	card_id = card_id.replace("'", "")
	var data : Dictionary = {
		"id": card_id,
		"type": type,
		"subject": subject,
		"code": lesson_code,
		"lesson": lesson,
		"duration": duration,
		"teacher": teacher,
		"obligatory": obligatory,
		"room": room,
		"color": color,
		"schedule": schedule,
		"is_displayed": false,
	}
	return data
	

func update_color(color:String) -> void:
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(color))
	new_style.set_corner_radius_individual(15,15,0,0)
	head_panel.set('custom_styles/panel', new_style)

##________________Methodes connectees par signal_______________________________
func _on_CancelButton_pressed() -> void:
	hide()



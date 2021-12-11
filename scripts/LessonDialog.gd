extends Control


var subjects_and_lessons_are_ready := false
var card_color : String = "#1e90ff"

var rating : int

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
onready var location_option_button : OptionButton = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/LocationOptionButton
onready var note_text_edit :TextEdit = $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/NoteTextEdit
onready var title : Label = $Panel/VBoxContainer/Head/Title
onready var head_panel : Panel = $Panel/VBoxContainer/Head
onready var panel : Panel = $Panel
onready var vbox_container := $Panel/VBoxContainer/Body/VboxContainer
onready var body : CenterContainer = $Panel/VBoxContainer/Body
onready var stars_container :HBoxContainer= $Panel/VBoxContainer/Body/VboxContainer/ScrollContainer/GridContainer/StarsContainer



func _ready() -> void:
	Signals.connect("database_reseted",self, "_on_database_reseted")
	Signals.connect("lessons_database_updated", self, "_lesson_refreshed")
	Signals.connect("subjects_database_updated", self, "_subject_refreshed")
	Signals.connect("locations_database_updated", self, "_location_refreshed")
	for btn in stars_container.get_children():
		btn.connect("mouse_hover", self, "_on_star_btn_overflew")
		btn.connect("mouse_out", self, "_on_star_btn_overflew")
		btn.connect("mouse_pressed", self, "_on_star_btn_toggled")
	pass

## Permet un affichage responsive
func _physics_process(delta):
	if  self.rect_size.y >= 980:
		panel.rect_size.y = 960
		vbox_container.rect_size.y = 790
		vbox_container.margin_top = 40
		_set_panel_to_center(0,-5)
		return
	_set_panel_to_center(0,0)
	panel.rect_size.y = 680
	vbox_container.rect_size.y = 543
	
func _set_panel_to_center(xoffset:int = 0, yoffset:int = 0):
	var xpos: int = (self.rect_size.x/2)-(panel.rect_size.x/2)
	var ypos: int = (self.rect_size.y/2)-(panel.rect_size.y/2)
	panel.rect_position = Vector2(xpos + xoffset, ypos + yoffset)

##______________Verifications avant validation du cours________________________
func check_subject_lesson_database() ->bool:
	if Global.subjects_database.empty():
		notification.text = "Vous devez ajouter une matière !"
		return false
	if Global.lessons_database.empty():
		notification.text = "Vous devez ajouter un cours !"
		return false
	if Global.locations_database.empty():
		notification.text = "Vous devez ajouter un lieu d'enseignement !"
		return false
	notification.text = ""
	return true


func _check_lesson_duration() ->bool:
	if Global.get_item_string(duration_hours_option_button) == "0" and Global.get_item_string(duration_minutes_option_button) == "00":
		notification.text = "Vous devez indiquer un durée de cours valide!"
		return false
	notification.text = ""
	return true


func check_for_validation(node_path) :
	var is_safe = IsSafe.new()
	if (not is_safe.string(note_text_edit.text) or 
		not is_safe.string(teacher_line_edit.text) or 
		not is_safe.string(room_line_edit.text) or 
		not is_safe.string(lesson_code_line_edit.text)):
		return
	if not check_subject_lesson_database():
		return false
	if not _check_lesson_duration():
		return false
	if check_if_lesson_exists():
		notification.text = "Ce cours existe déjà !"
		return false
	if room_line_edit.text == "":
		notification.text = ""
		Signals.emit_signal("error_emitted", "RoomNotFound", node_path) ## To AlertDialog by Main
		return false
	return true



func check_if_lesson_exists():
	var time = Time.new()
	var id = ID.new()
	var card_id :String = id.generate(subject_option_button.text, 
										lesson_option_button.text, 
										type_option_button.text, 
										schedule_days_option_button.text, 
										str(time.get_minutes([schedule_hours_option_button.text, schedule_minutes_option_button.text])),
										location_option_button.text, 
										room_line_edit.text
										)
	if Global.left_panel.does_lesson_exist(card_id, type_option_button.text):
		return true
	return false



##_______________Creation et envoie des donnees par signal________________________
func _get_schedule() ->Dictionary:
	var time = Time.new()
	var duration :int = time.get_minutes([Global.get_item_string(duration_hours_option_button), Global.get_item_string(duration_minutes_option_button)])
	var day = Global.get_item_string(schedule_days_option_button)
	var start :int = time.get_minutes([Global.get_item_string(schedule_hours_option_button), Global.get_item_string(schedule_minutes_option_button)])
	var end :int = start + duration
	return {"day":day, "start":start, "duration":duration, "end":end}

func create_data_dictionary() -> Dictionary:
	var type = Global.get_item_string(type_option_button)
	var subject = Global.get_item_string(subject_option_button)
	var lesson = Global.get_item_string(lesson_option_button)
	var time :Time = Time.new() 
	var teacher = teacher_line_edit.text
	var lesson_code = lesson_code_line_edit.text
	var room = room_line_edit.text
	var obligatory = obligatory_check_button.is_pressed()
	var color = card_color
	var location = Global.get_item_string(location_option_button)
	var schedule = _get_schedule()
	var note = note_text_edit.text
	var id = ID.new()
	var card_id :String = id.generate(subject, lesson, type, schedule["day"], str(schedule["start"]), location, room)
	var index = 0
	var data : Dictionary = {
		"id": card_id,
		"type": type,
		"subject": subject,
		"lesson_code": lesson_code,
		"lesson": lesson,
		"teacher": teacher,
		"is_obligatory": obligatory,
		"room": room,
		"color": color,
		"schedule": schedule,
		"is_displayed": false,
		"index": index,
		"rating":rating,
		"location": location,
		"note": note
	}
	return data
	

##____________ Gestion de la GUI ________________
func reset_default_GUI() ->void:
	type_option_button.select(0)
	_subject_refreshed()
	_lesson_refreshed()
	_location_refreshed()
	room_line_edit.text = ""
	duration_hours_option_button.select(0)
	duration_minutes_option_button.select(0)
	schedule_days_option_button.select(0)
	schedule_hours_option_button.select(0)
	schedule_minutes_option_button.select(0)
	teacher_line_edit.text = ""
	lesson_code_line_edit.text = ""
	obligatory_check_button.set_pressed(false)
	note_text_edit.text = ""
	reset_notification()
	title.text = "Nouveau cours"
	for star in stars_container.get_children():
		star.set_is_pressed(false)
	

func _subject_refreshed() ->void: ## From NewSubjectDialog and SaveSystem.gd by Signals
	Global.update_option_button(subject_option_button, Global.subjects_database)
	_lesson_refreshed()


func _lesson_refreshed() ->void: ## From NewSubjectDialog and SaveSystem.gd by Signals
	var subject_selected: String = ""
	if !Global.subjects_database.empty():
		subject_selected = subject_option_button.get_item_text(0)
	Global.update_option_button(lesson_option_button, Global.lessons_database, subject_selected)


func _location_refreshed() ->void:
	Global.update_option_button(location_option_button, Global.get_locations_database())


func reset_notification() ->void:
	notification.text = ""

func update_color(color:String) -> void:
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(color))
	new_style.set_corner_radius_individual(15,15,0,0)
	head_panel.set('custom_styles/panel', new_style)


func refresh_rating_gui():
	for btn in stars_container.get_children():
		btn.set_is_pressed(false)
		if btn.value <= rating:
			btn.set_is_pressed(true)


func _use_same_color_as_CM() ->void:
	if not Preferences.TD_is_same_color_as_CM:
		return
	if Global.get_item_string(type_option_button) != "Travaux Dirigés":
		return
	for card in get_tree().get_nodes_in_group("CM_lesson_cards"):
		if card.lesson == Global.get_item_string(lesson_option_button):
			update_color(card.color)


##________________Methodes connectees par signal_______________________________
func _on_star_btn_overflew(value:int):
	for btn in stars_container.get_children():
		if btn.value <= value:
			btn.overflew(true)
		else:
			btn.overflew(false)


func _on_star_btn_toggled(value, is_pressed):
	if rating != value:
		rating = value	
		for btn in stars_container.get_children():
			if btn.value <= value and !btn.is_pressed:
				btn.set_is_pressed(true)
			elif btn.value == value and btn.is_pressed:
				btn.set_is_pressed(true)
			elif btn.value > value:
				btn.set_is_pressed(false)
	else:
		rating = 0
		for btn in stars_container.get_children():
			btn.set_is_pressed(false)


func _on_database_reseted(database_name:String) -> void:
	if database_name == "subjects_database":
		_subject_refreshed()
	if database_name == "lessons_database":
		_lesson_refreshed()
	if database_name == "locations_database":
		_location_refreshed()


func _on_CancelButton_pressed() -> void:
	reset_notification()
	reset_default_GUI()
	hide()


func _on_SubjectOptionButton_item_selected(index):
	var subject_selected: String = subject_option_button.get_item_text(index)
	Global.update_option_button(lesson_option_button, Global.lessons_database, subject_selected)



func _on_StarsContainer_mouse_exited():
	for btn in stars_container.get_children():
		btn.overflew(false)

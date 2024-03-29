extends Button
class_name LessonCard

signal lesson_cell_updated(datas)

onready var is_displayed_bg = preload("res://res/button_lesson_card_in_schedule.tres")
onready var is_not_displayed_bg = preload("res://res/button_lesson_card_normal.tres")
onready var is_not_displayed_bg_hover = preload("res://res/button_lesson_card_hover.tres")
onready var _conflict_lesson_bg = preload("res://res/button_lesson_card_conflict.tres") 
onready var _conflict_lesson_bg_hover = preload("res://res/button_lesson_card_conflict_hover.tres")

var id :String
var type :String
var subject : String
var lesson_code : String
var schedule : Dictionary
var is_obligatory : bool
var room : String
var lesson : String
var teacher : String
var color : String = "#00acb4"
var csv_datetime: Array
var save_date: Dictionary = {"created": "", "edited": "", "saved": ""} ## Date de création et modification de la carte
var rating : int = 0 ## Permet de noter le cours avec des etoiles
var is_displayed : bool = false setget _set_is_displayed
var size : int ## Nombre de tuiles que le cours occupe dans l'agenda
var version : float
var position := Vector2.ZERO
var index : int 
var location: String
var note : String

var is_in_conflict : bool setget _set_is_in_conflict

onready var header_panel := $VBoxContainer/Header
onready var title_label := $VBoxContainer/Header/Title
onready var type_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/TypeField
onready var subject_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/SubjectField
onready var lesson_code_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/LessonCodeField
onready var duration_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/DurationField
onready var schedule_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/ScheduleField
onready var obligatory_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/ObligatoryField
onready var room_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/RoomField
onready var teacher_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/TeacherField
onready var displayed_field := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/DisplayedField
onready var stars_container := $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/StarsContainer
onready var location_field : Label = $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/LocationField
onready var note_field : Label = $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/NoteField
onready var grid_container : GridContainer = $VBoxContainer/HBoxContainer/VBoxContainer/GridContainer



##_____________Methodes d'initialisation__________________________
func _ready():
	version = ProjectSettings.get_setting("application/config/version")
	Signals.connect("lesson_removed_from_calendar", self, "_undisplay")
	Signals.connect("program_reseted", self, "delete") ## Header -> Signals
	Signals.connect("updating_conflicts", self, "set_conflicts") ## CellButton -> Signals
	Signals.connect("updating_conflicts", self, "refresh_is_in_conflict_GUI") ## CellButton -> Signals
	Signals.connect("set_color_same_as_CM_emitted", self, "_on_set_color_same_as_CM_emitted")
	Signals.connect("route_created", self, "_on_route_edited")
	Signals.connect("route_deleted", self, "_on_route_edited")
	save_date["created"] = OS.get_datetime()
	

##______________setter et getter prives___________________________

func _set_is_displayed(value) ->void:
	is_displayed = value
	if is_displayed:
		add_to_group("lesson_cards_displayed")
	else:
		if self.is_in_group("lesson_cards_displayed"):
			remove_from_group("lesson_cards_displayed")
	_update_background()


func _set_is_in_conflict(value) ->void:
	is_in_conflict = value
	refresh_is_in_conflict_GUI()
	

##_______________Gestion d'acces aux donnees____________________________

func get_data() ->Dictionary:
	var data = {
	"id": id,
	"type" : type,
	"subject": subject,
	"lesson_code" : lesson_code,
	"schedule" : schedule,
	"is_obligatory" : is_obligatory,
	"room" : room,
	"lesson" : lesson,
	"teacher" : teacher,
	"color" : color,
	"csv_datetime" : csv_datetime,
	"save_date": save_date,
	"rating" : rating,
	"is_displayed" : is_displayed,
	"size" : size,
	"position":position,
	"version": version,
	"index": index,
	"location": location,
	"note" : note
	}
	return data


func set_data(data:Dictionary) -> void:
	type = data["type"]
	lesson = data["lesson"]
	subject = data["subject"]
	id = data["id"]
	teacher = data["teacher"]
	lesson_code = data["lesson_code"]
	is_obligatory = data["is_obligatory"]
	room = data["room"]
	color = data["color"]
	schedule = data["schedule"]
	is_displayed = data["is_displayed"]
	index = data["index"]
	location = data["location"]
	note = data["note"]
	if data.has("save_date"):
		save_date = data["save_date"]
	if data.has("rating"):
		rating = data["rating"]
	if data.has("size"):
		size = data["size"]
	if data.has("position"):
		position = data["position"]
	update_GUI()
	set_conflicts()
	set_CM_lessons_cards_group()
	print(get_tree().get_nodes_in_group("CM_lesson_cards"))


func set_CM_lessons_cards_group() ->void:
	print("Hello 1")
	if self.is_in_group("CM_lesson_cards") and type != "Cours Magistral":
		self.remove_from_group("CM_lesson_cards")
		print("Hello 2")
		return
	if not self.is_in_group("CM_lesson_cards") and type == "Cours Magistral":
		print("Hello 3")
		add_to_group("CM_lesson_cards")
		return
	print("Hello 4")


##________________Methodes de calcule___________________________
func _calculate_position(schedule: Dictionary) ->Vector2:
	var time = Time.new()
	var schedule_table:Array = time.get_time_24h(schedule["start"])
	var x = _find_x_pos(schedule["day"])
	var hours = int(schedule_table[0])
	var minutes = int(schedule_table[1])
	var y = (hours-7)*2
	if minutes > 0:
		y += 1
	return Vector2(x,y)


func _find_x_pos(day:String) -> int:
	return Global.weekday.find(day)

# Calcule la taille du cours lorsqu'il est affiche dans l'agenda
func _calcul_size(duration: int) ->int:
	var time := Time.new()
	var duration_table:Array = time.get_time_24h(duration)
	var hours = int(duration_table[0])
	var minutes = int(duration_table[1])
	var nbr_cells : int = hours * 2
	if minutes > 0:
		nbr_cells += 1
	return nbr_cells


##_________________ Verification avancee des conflits entre cours______________

##Retourne dans un tableau tous les cours qui sont en conflit avec ce cours
func search_conflicts_with_lessons() -> Array:
	var list_of_conflicts :Array
	for card in get_tree().get_nodes_in_group("lesson_cards_displayed"):
		if card != self:
#			print_debug("self start: %s / end: %s" %[schedule["start"], schedule["end"]])
#			print_debug("card start: %s / end: %s" %[card.schedule["start"], card.schedule["end"]])
			var travel_time: int = 0
			if card.location != location:
				travel_time = Global.get_travel_time_between(card.location, location)
			if Conflict.is_in_conflict_with(schedule, card.schedule, travel_time):
				list_of_conflicts.append(card)
	return list_of_conflicts


func search_conflicts_with_cells() -> Array:
	var list_of_conflicts:Array
	for cell in get_tree().get_nodes_in_group("occupied_cells"):
		if Conflict.is_in_conflict_with(schedule, cell.schedule, 0):
			list_of_conflicts.append(cell)
			print("Search conflict with cell")
	return list_of_conflicts


func does_conflict_exist() ->bool:
	if search_conflicts_with_lessons().empty() and search_conflicts_with_cells().empty():
		return false
	return true

func set_conflicts() ->void:	
	if does_conflict_exist():
		self.is_in_conflict = true
	else:
		self.is_in_conflict = false

##_______________Mise a jour de la GUI______________

func update_GUI() -> void:
	var time :Time= Time.new()
	title_label.text = lesson
	type_field.text = type
	subject_field.text = subject
	lesson_code_field.text = lesson_code
	teacher_field.text = teacher
	room_field.text = room
	duration_field.text = time.get_time_24h_str(schedule["duration"], "h")
	schedule_field.text = "%s %s à %s" %[String(schedule["day"]), time.get_time_24h_str(schedule["start"], "h"), time.get_time_24h_str(schedule["end"], "h")]
	update_color(color)
	_refresh_rating_gui()
	location_field.text = location
	if is_obligatory:
		obligatory_field.text = "oui"
	if not is_obligatory:
		obligatory_field.text = "non"
	size = _calcul_size(schedule["duration"])
	position = _calculate_position(schedule)
	emit_signal("lesson_cell_updated", get_data(), "")
	note_field.text = note
	

func _refresh_rating_gui():
	for star in stars_container.get_children():
		star.hide()
		if rating == star.get_index():
			star.show()

func refresh_is_in_conflict_GUI():
	if is_in_conflict:
		self.add_stylebox_override("normal", _conflict_lesson_bg)
		self.add_stylebox_override("hover", _conflict_lesson_bg_hover)
#		self.set_card_labels_font_color("FFFFFF")
	else:
		_update_background()
#		self.set_card_labels_font_color("#383838")	
	
func update_color(new_color:String) -> void:
	self.color = new_color
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(color))
	new_style.set_corner_radius_individual(10,10,0,0)
	header_panel.set('custom_styles/panel', new_style)


func set_card_labels_font_color(color:String) ->void:
	for label in grid_container.get_children():
		if label is Label:
			label.set("custom_colors/font_color", Color(color))

func _update_background():
	if is_displayed:
		self.add_stylebox_override("normal", is_displayed_bg)
		self.add_stylebox_override("hover", is_displayed_bg)
		return
	self.add_stylebox_override("normal", is_not_displayed_bg)
	self.add_stylebox_override("hover", is_not_displayed_bg_hover)


##__________________Methodes d'import / export des donnees et suppression________________	

func delete()->void:
	if is_displayed == true:
		Signals.emit_signal("removing_lesson_from_calendar", position, size, id)
		self.is_displayed = false
	self.queue_free()


func load_data(data:Dictionary) ->void:
	if data.has("position"):
		data["position"] = str2var(data["position"]) as Vector2
	set_data(data)
	if data["is_displayed"] == true:
		var node_path : NodePath = self.get_path()
		Global.calendar_array.add_lesson(node_path)


func save_to_res() -> Dictionary:
	var data: Dictionary = get_data()
	data["position"] = var2str(Vector2(data["position"]))
	return data



func load_from_var(file: File) -> void:
	var datas = get_data()
	for data in datas:
		data[str2var(file.get_line())]
	set_data(datas)

		
func export_to_json() ->Dictionary:
	var data: Dictionary = get_data()
	data["is_displayed"] = false
	data["rating"] = 0
	data["position"] = var2str(Vector2(data["position"]))
	return data


func export_to_csv() ->PoolStringArray:
#	var subject :String = str(datas["type"] + " " + datas["lesson"])
	var subject :String = str(type + " " + lesson)
	var start_date :String = str(csv_datetime[0][0]) + "/" + str(csv_datetime[0][1]) + "/" + str(csv_datetime[0][2])
	var start_time : String = csv_datetime[1][0]
	var end_date : String = start_date
	var end_time : String = csv_datetime[1][1]
	var all_day : String = "False"
	var description : String = "Prof. %s" %teacher
	var location : String = "%s Salle %s" %[location, room]
	var private : String = "True" 
	var array :PoolStringArray = [subject, start_date, start_time, end_date, end_time, all_day, description, location, private]
	return array
	
	
	
##_______________________Methodes connectees_______________________________


## Le cours n'est plus affiche dans le calendrier
func _undisplay(card_id:String):
	if card_id == id:
		self.is_displayed = false

func _on_set_color_same_as_CM_emitted(new_color:String, lesson_name:String) ->void:
	if lesson_name != lesson:
		return
	update_color(new_color)


func _on_route_edited(location_A:String, location_B:String) ->void:
	if !self.is_displayed:
		return
	if location_A == location or location_B == location:
		self.is_displayed = false
		Signals.emit_signal("removing_lesson_from_calendar", position, size, id)
		

func _on_LessonCard_gui_input(event):
	var node_path : NodePath = self.get_path()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				#if Input.is_key_pressed("delete"):
				if Input.is_action_pressed("delete"):
					self.delete()
					return
				Signals.emit_signal("lesson_card_pressed", node_path) ## -> Signals -> EditLessonDialog
			BUTTON_RIGHT:
				if is_in_conflict:
					Signals.emit_signal("error_emitted", "FilledCell", null)
					return
				if is_displayed:
					if is_obligatory:
						Signals.emit_signal("error_emitted", "ObligatoryLesson", node_path) # -> Signals -> AlertDialog 
					else:
						Signals.emit_signal("removing_lesson_from_calendar", position, size, id)
					return
				Global.calendar_array.add_lesson(node_path)


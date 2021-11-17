extends Button

signal lesson_cell_updated(datas)

onready var is_displayed_bg = preload("res://res/button_lesson_card_in_schedule.tres")
onready var is_not_displayed_bg = preload("res://res/button_lesson_card_normal.tres")
onready var is_not_displayed_bg_hover = preload("res://res/button_lesson_card_hover.tres")

var id :String
var type :String
var subject : String
var lesson_code : String
var duration : int
var schedule : Array
var is_obligatory : bool
var room : String
var lesson : String
var teacher : String
var color : String = "#00acb4"
var datetime: Array
var save_date: Dictionary = {"created": "", "edited": "", "saved": ""} ## Date de création et modification de la carte
var rating : int = 0 ## Permet de noter le cours avec des etoiles
var is_displayed : bool = false setget _set_is_displayed
var size : int ## Nombre de tuiles que le cours occupe dans l'agenda
var version : float
var position := Vector2.ZERO
var index : int 
var location: String
var note : String

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



##_____________Methodes d'initialisation__________________________
func _ready():
	version = ProjectSettings.get_setting("application/config/version")
	Signals.connect("lesson_removed_from_calendar", self, "_undisplay")
	Signals.connect("program_reseted", self, "delete") ## Header -> Signals
	save_date["created"] = OS.get_datetime() 

##______________setter et getter prives___________________________

func _set_is_displayed(value) ->void:
	is_displayed = value
	_update_background()
	

##_______________Gestion d'acces aux donnees____________________________

func get_data() ->Dictionary:
	var data = {
	"id": id,
	"type" : type,
	"subject": subject,
	"lesson_code" : lesson_code,
	"duration" : duration,
	"schedule" : schedule,
	"is_obligatory" : is_obligatory,
	"room" : room,
	"lesson" : lesson,
	"teacher" : teacher,
	"color" : color,
	"datetime" : datetime,
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
	duration = data["duration"]
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




##________________Methodes de calcule___________________________
func _calculate_position(schedule: Array) ->Vector2:
	var time = Time.new()
	var schedule_table:Array = time.get_time_24h(duration)
	var x = schedule[0]
	var hours = int(schedule_table[0])
	var minutes = int(schedule_table[1])
	var y = (hours-7)*2
	if minutes > 0:
		y += 1
	return Vector2(x,y)

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


##_______________Mise a jour de la GUI______________

func update_GUI() -> void:
	var time :Time= Time.new()
	title_label.text = lesson
	type_field.text = type
	subject_field.text = subject
	lesson_code_field.text = lesson_code
	teacher_field.text = teacher
	room_field.text = room
	duration_field.text = time.get_time_24h_str(duration, "h")
	schedule_field.text = "%s %s à %s" %[String(schedule[1]), time.get_time_24h_str(schedule[2], "h"), time.get_time_24h_str(schedule[2] + duration, "h")]
	update_color(color)
	_refresh_rating_gui()
	location_field.text = location
	if is_obligatory:
		obligatory_field.text = "oui"
	if not is_obligatory:
		obligatory_field.text = "non"
	size = _calcul_size(duration)
	position = _calculate_position(schedule)
	emit_signal("lesson_cell_updated", get_data(), "")

func _refresh_rating_gui():
	for star in stars_container.get_children():
		star.hide()
		if rating == star.get_index():
			star.show()
	
	
func update_color(color:String) -> void:
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(color))
	new_style.set_corner_radius_individual(10,10,0,0)
	header_panel.set('custom_styles/panel', new_style)


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



#func save_to_var(file: File) -> void:
#	var datas = get_data()
#	for data in datas:
#		file.store_line(var2str(data))


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
	var start_date :String = str(datetime[0][0]) + "/" + str(datetime[0][1]) + "/" + str(datetime[0][2])
	var start_time : String = datetime[1][0]
	var end_date : String = start_date
	var end_time : String = datetime[1][1]
	var all_day : String = "False"
	var description : String = "Prof. %s" %teacher
	var location : String = "Salle %s" %room
	var private : String = "False" 
	var array :PoolStringArray = [subject, start_date, start_time, end_date, end_time, all_day, description, location, private]
	return array
	
	
	
##_______________________Methodes connectees_______________________________


## Le cours n'est plus affiche dans le calendrier
func _undisplay(card_id:String):
	if card_id == id:
		self.is_displayed = false


func _on_LessonCard_gui_input(event):
	var node_path : NodePath = self.get_path()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				if Input.is_key_pressed(KEY_CONTROL):
					self.delete()
					return
				Signals.emit_signal("lesson_card_pressed", node_path) ## -> Signals -> EditLessonDialog
			BUTTON_RIGHT:
				if is_displayed:
					if is_obligatory:
						Signals.emit_signal("error_emitted", "ObligatoryLesson", node_path) # -> Signals -> AlertDialog 
					else:
						Signals.emit_signal("removing_lesson_from_calendar", position, size, id)
					return
				Global.calendar_array.add_lesson(node_path)


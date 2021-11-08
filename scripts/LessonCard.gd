extends Button

signal updating_lesson_cell(datas)

onready var is_displayed_bg = preload("res://res/button_lesson_card_in_schedule.tres")
onready var is_not_displayed_bg = preload("res://res/button_lesson_card_normal.tres")
onready var is_not_displayed_bg_hover = preload("res://res/button_lesson_card_hover.tres")

var id :String
var type :String
var subject : String
var lesson_code : String
var duration : Array
var schedule : Array
var is_obligatory : bool
var room : String
var lesson : String
var teacher : String
var color : String = "#00acb4"
var datetime: Array
var rating : int ## Permet de noter le cours avec des etoiles
var is_displayed : bool = false setget _set_is_displayed
var size : int ## Nombre de tuiles que le cours occupe dans l'agenda
var x : int
var y : int

var datas : Dictionary

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


func _set_is_displayed(value) ->void:
	is_displayed = value
	_update_background()
	

##_______________Methodes d'affichage de la classe____________________________
func _update_background():
	if is_displayed:
		self.add_stylebox_override("normal", is_displayed_bg)
		self.add_stylebox_override("hover", is_displayed_bg)
		return
	self.add_stylebox_override("normal", is_not_displayed_bg)
	self.add_stylebox_override("hover", is_not_displayed_bg_hover)


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
	"rating" : rating,
	"is_displayed" : is_displayed,
	"size" : size,
	"x" : x,
	"y" : y
	}
	return data

##Non utilisee pour l'instant
#func set_data(data:Dictionary) ->void:
#	if data.has("id"):
#		id = data["id"]
#	if data.has("type"):
#		type = data["type"]
#	if data.has("subject"):
#		subject = data["subject"]
#	if data.has("lesson_code"):
#		lesson_code = data["lesson_code"]
#	if data.has("duration"):
#		duration = data["duration"]
#	if data.has("schedule"):
#		schedule = data["schedule"]
#	if data.has("is_obligatory"):
#		is_obligatory = data["is_obligatory"]
#	if data.has("room"):
#		room = data["room"]
#	if data.has("lesson"):
#		lesson = data["lesson"]
#	if data.has("teacher"):
#		teacher = data["teacher"]
#	if data.has("color"):
#		color = data["color"]
#	if data.has("datetime"):
#		datetime = data["datetime"]
#	if data.has("is_displayed"):
#		is_displayed = data["is_displayed"]
#	if data.has("rating"):
#		rating = data["rating"]
#	if data.has("size"):
#		size = data["size"]



func assigning_dictionary_values(datas_arg:Dictionary) -> void:
	type = datas_arg["type"]
	lesson = datas_arg["lesson"]
	subject = datas_arg["subject"]
	id = datas_arg["id"]
	teacher = datas_arg["teacher"]
	lesson_code = datas_arg["code"]
	duration = datas_arg["duration"]
	is_obligatory = datas_arg["obligatory"]
	room = datas_arg["room"]
	color = datas_arg["color"]
	schedule = datas_arg["schedule"]
	is_displayed = datas_arg["is_displayed"]
	datas = datas_arg



func update_infos() -> void:
	title_label.text = lesson
	type_field.text = type
	subject_field.text = subject
	lesson_code_field.text = lesson_code
	teacher_field.text = teacher
	room_field.text = room
	duration_field.text = "%sh%s" %[String(duration[0]), String(duration[1])]
	schedule_field.text = "%s %sh%s à %s" %[String(schedule[1]), String(schedule[2]), String(schedule[3]), calculate_time(duration, schedule)]
	update_color(color)
	if is_obligatory:
		obligatory_field.text = "oui"
	if not is_obligatory:
		obligatory_field.text = "non"
	_calcul_size(duration)
	_caculate_position(schedule)
	emit_signal("updating_lesson_cell", datas)



##________________Methodes de calcule___________________________
## Renvoie un affichage de la date sous format 24H00
func calculate_time(duration, schedule)->String:
	var hours = int(duration[0]) + int(schedule[2])
	var minutes = "30"
	if int(duration[1]) + int(schedule[3]) >= 60:
		hours += 1
		minutes = "00"
	if int(duration[1]) + int(schedule[3]) < 30:
		minutes = "00"
	return String(hours) + "h" + minutes


## Calcule la position de la cellule lorsque le cours est affiche dans l'agenda
func _caculate_position(schedule: Array) ->void:
	x = schedule[0]
	var hours = int(schedule[2])
	var minutes = int(schedule[3])
	y = (hours-7)*2
	if minutes > 0:
		y += 1


# Calcule la taille du cours lorsqu'il est affiche dans l'agenda
func _calcul_size(duration: Array) ->void:
	var hours = int(duration[0])
	var minutes = int(duration[1])
	var nbr_cells : int = hours * 2
	if minutes > 0:
		nbr_cells += 1
	size = nbr_cells
	

func update_color(color:String) -> void:
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(color))
	new_style.set_corner_radius_individual(10,10,0,0)
	header_panel.set('custom_styles/panel', new_style)


##__________________Methodes d'exportation des donnees________________	
	
func export_to_json() ->Dictionary:
	datas["is_displayed"] = false
	return datas


func export_to_csv() ->PoolStringArray:
	var subject :String = str(datas["type"] + " " + datas["lesson"])
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
	
	
	
##_______________Fonctions connectees_______________________________

func _on_LessonCard_gui_input(event):
	var node_path : NodePath = self.get_path()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				Signals.emit_signal("lesson_card_pressed", node_path) ## -> Signals -> EditLessonDialog
			BUTTON_RIGHT:
				if is_displayed:
					if is_obligatory:
						Signals.emit_signal("error_emitted", "ObligatoryLesson", node_path) # -> Signals -> AlertDialog 
					else:
						Signals.emit_signal("deleting_lesson_from_calendar", x, y, size, id)
					return
				Global.calendar_array.add_lesson(node_path)


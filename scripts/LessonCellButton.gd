extends Button

var is_empty := false
var position:= Vector2.ZERO
var size := 0
var id :String
var datas : Dictionary
var is_obligatory : bool

onready var infos : Label = $CenterContainer/VBoxContainer/Infos

func _ready():
	Signals.connect("lesson_edited", self, "update_cell")
	infos.text = "%s \n %s \n Salle %s \n Prof. %s" %[datas["lesson"], datas["type"], datas["room"], datas["teacher"]]


func init_cell(xpos, ypos, size_arg, datas_arg:Dictionary) ->void:
	size = size_arg
	rect_min_size.y = (size * self.rect_min_size.y)
	position.x = xpos
	position.y = ypos
	id = datas_arg["id"]
	datas = datas_arg
	is_obligatory = datas_arg["is_obligatory"]
	_color_table(datas_arg["color"])
	
func update_cell(datas_arg: Dictionary, _old_id:String) ->void:
	infos.text = "%s \n %s \n Salle %s \n Prof. %s" %[datas_arg["lesson"], datas_arg["type"], datas_arg["room"], datas_arg["teacher"]]
	id = datas_arg["id"]
	is_obligatory = datas_arg["is_obligatory"]
	_color_table(datas_arg["color"])
	

func _update_color(background:String, borders:String) ->void:
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(background))
	new_style.border_color = Color(borders)
	new_style.set_border_width_all(1)
	set('custom_styles/normal', new_style)

func _on_LessonCellButton_gui_input(event):
	var node_path : NodePath = self.get_path()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				Signals.emit_signal("lesson_cell_opened", id) # To LeftPanel by Signals
			BUTTON_RIGHT:
				if is_obligatory:
					Signals.emit_signal("error_emitted", "ObligatoryLesson", node_path) # -> Signals -> AlertDialog 
				else:
					Signals.emit_signal("lesson_from_calendar_deleted", position, size, id)

	
	
	
## Permet d'adapter la couleur de la cellule en fonction de la couleur de la carte
func _color_table(color:String) ->void:
	match color:
		"#1e90ff": #DodgerBlue
			if not is_obligatory:
				_update_color("#e7f3ff", "#1eb0ff")
			else:
				_update_color("#a6d2fe", "#1eb0ff")
			
		"#282897": #DarkBlue
			if not is_obligatory:
				_update_color("#e7edff", "#254aad")
			else:
				_update_color("#b3c6ff", "#254aad")
				
		"#632e99": #Purple
			if not is_obligatory:
				_update_color("#f3e6ff", "#5c2891")
			else:
				_update_color("#d7abff", "#5c2891")
			
		"#a83374": #Magenta	
			if not is_obligatory:
				_update_color("#ffe1f2", "#6b1243")
			else:
				_update_color("#ffa2d7", "#6b1243")
				
		"#971818": #Red
			if not is_obligatory:
				_update_color("#ffcece", "#750e0e")
			else:
				_update_color("#ff9d9d", "#750e0e")

		"#eb760c": #Orange
			if not is_obligatory:
				_update_color("#ffe9d4", "#9c5617")
			else:
				_update_color("#fec792", "#9c5617")

		"#facf39": #Yellow
			if not is_obligatory:
				_update_color("#fff6d7", "#ad8008")
			else:
				_update_color("#ffe897", "#ad8008")

		"#85c533": #LightGreen
			if not is_obligatory:
				_update_color("#ebfed1", "#5b8e19")
			else:
				_update_color("#d0ff8f", "#5b8e19")

		"#228b22": #ForestGreen
			if not is_obligatory:
				_update_color("#d5ffd5", "#0d7a0d")
			else:
				_update_color("#96ff96", "#0d7a0d")

		"#2b2b2b": #Black
			if not is_obligatory:
				_update_color("#ededed", "#1a1a1a")
			else:
				_update_color("#c1c1c1", "#1a1a1a")



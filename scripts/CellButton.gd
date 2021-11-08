extends Button

var red_style = preload("res://res/calendar_cell_normal_red.tres")
var normal_style = preload("res://res/calendar_cell_normal.tres")

var is_empty := true
var position := Vector2.ZERO
var size := 1

onready var label := $Label



func add_coord_to_cell(xpos:int, ypos:int) ->void:
	position.x = xpos
	position.y = ypos
	$Label.text = "(%s, %s)" % [position.x, position.y]
	

func _turn_cell_to_occupied() -> void:
	is_empty = false
	self.custom_styles.normal.bg_color = "#ff9595"
	self.custom_styles.set_bg_color(Color("#bada55"))

func set_cell() ->void:
	if is_empty:
		is_empty = false
		self.add_stylebox_override("normal", red_style)
		return
	is_empty = true
	self.add_stylebox_override("normal", normal_style)


func _on_CellButton_gui_input(event):
	var node_path : NodePath = self.get_path()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				set_cell()
			BUTTON_RIGHT:
				set_cell()


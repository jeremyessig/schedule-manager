extends Button

var red_style = preload("res://res/calendar_cell_normal_red.tres")
var normal_style = preload("res://res/calendar_cell_normal.tres")

var is_empty := true
var position := Vector2.ZERO
var size := 1
var schedule : Dictionary
var start:int
#const duration:int = 30
#var end :int
#var day : String

onready var label := $Label

func add_coord_to_cell(xpos:int, ypos:int) ->void:
	position.x = xpos
	position.y = ypos
#	$Label.text = "(%s, %s)" % [position.x, position.y]
	set_cell_time(position.y)
	$Label.text = "(%s, %s, %s)" %[schedule["start"], schedule["end"], schedule["duration"]]


func set_cell_time(index:int) ->void:
	var start = 420 + (index * 30) # 420 / 60 = 7h00
	var end = start + 30
	var day = Global.weekday[position.x]
	schedule = {"start": start, "duration": 30, "end":end, "day": day}
	

#func _turn_cell_to_occupied() -> void:
#	is_empty = false
#	self.custom_styles.normal.bg_color = "#ff9595"
#	self.custom_styles.set_bg_color(Color("#bada55"))

func set_cell() ->void:
	if is_empty:
		is_empty = false
		self.add_stylebox_override("normal", red_style)
		add_to_group("occupied_cells")
		Signals.emit_signal("updating_conflicts")
		return
	is_empty = true
	remove_from_group("occupied_cells")
	self.add_stylebox_override("normal", normal_style)
	Signals.emit_signal("updating_conflicts")


func _on_CellButton_gui_input(event):
	var node_path : NodePath = self.get_path()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				set_cell()
			BUTTON_RIGHT:
				set_cell()


extends Button

var png_style = preload("res://res/cells/calendar_cell_normal_png.tres")
var red_style = preload("res://res/calendar_cell_normal_red.tres")
var normal_style = preload("res://res/calendar_cell_normal.tres")

var is_empty := true
var position := Vector2.ZERO
var size := 1
var schedule : Dictionary
var start:int


onready var label := $Label

func _ready():
	Signals.connect("png_export_started", self, "_on_png_export_started")
	Signals.connect("png_export_ended", self, "_on_png_export_ended")
	Signals.connect("day_button_pressed", self, "_on_day_button_pressed")
	Signals.connect("time_button_pressed", self, "_on_time_button_pressed")


func reset() ->void:
	is_empty = true
	if self.is_in_group("occupied_cells"):
		remove_from_group("occupied_cells") ## -> Signals -> LessonCard
	self.add_stylebox_override("normal", normal_style)
	Signals.emit_signal("updating_conflicts") ## -> Signals -> LessonCard


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
	

func set_cell() ->void:
	if is_empty:
		is_empty = false
		self.add_stylebox_override("normal", red_style)
		add_to_group("occupied_cells")
		Signals.emit_signal("updating_conflicts")
		return
	reset()


func save_to_res() -> String:
	return var2str(Vector2(position))


func _on_day_button_pressed(x, empty) ->void:
	if position.x != x:
		return
	if is_empty != empty:
		return
	set_cell()
	
func _on_time_button_pressed(y, empty) ->void:
	if position.y != y:
		return
	if is_empty != empty:
		return
	set_cell()

func _on_png_export_started() ->void:
	if !is_empty:
		return
	self.set("custom_styles/normal", png_style)


func _on_png_export_ended() ->void:
	if !is_empty:
		return
	self.set("custom_styles/normal", normal_style)


func _on_CellButton_gui_input(event):
	var node_path : NodePath = self.get_path()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				set_cell()
			BUTTON_RIGHT:
				set_cell()



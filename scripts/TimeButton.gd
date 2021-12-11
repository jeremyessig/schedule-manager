extends Button

var font_normal = preload("res://res/Helvetica_normal.tres")
var font_bold = preload("res://res/Helvetica_bold.tres")
export var y : int

var is_empty : bool = true

onready var label = $Label

func _ready():
	Signals.connect("png_export_started", self, "_on_png_export_started")
	Signals.connect("png_export_ended", self, "_on_png_export_ended")
	y = get_position_in_parent()
	var minutes :int= 420 + (30 * y)
	label.text = Time.get_time_24h_str(minutes)


func _on_TimeLabel_pressed() -> void:
	Signals.emit_signal("time_button_pressed", y, is_empty)
	is_empty = !is_empty


func _on_png_export_started() ->void:
	label.set("custom_fonts/font", font_bold)
	
func _on_png_export_ended() ->void:
	label.set("custom_fonts/font", font_normal)

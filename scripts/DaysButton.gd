extends Button

signal day_button_pressed(value, boolean)
export var x : int
var is_empty : bool = true

var font_normal = preload("res://res/fonts/Helvetica_button.tres")
var font_bold = preload("res://res/Helvetica_bold.tres")

func _ready():
	Signals.connect("png_export_started", self, "_on_png_export_started")
	Signals.connect("png_export_ended", self, "_on_png_export_ended")
	
func _on_png_export_started() ->void:
	self.set("custom_fonts/font", font_bold)
	
func _on_png_export_ended() ->void:
	self.set("custom_fonts/font", font_normal)




func _on_Day_pressed():
	self.emit_signal("day_button_pressed", x, is_empty)
	is_empty = !is_empty

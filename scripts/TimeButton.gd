extends Button

signal time_button_pressed(value, boolean)

export var y : int

var is_empty : bool = true



func _on_TimeLabel_pressed() -> void:
	self.emit_signal("time_button_pressed", y, is_empty)
	is_empty = !is_empty

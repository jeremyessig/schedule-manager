extends Button

signal on_TimeLabel_pressed(value)

export var y : int



func _on_TimeLabel_pressed() -> void:
	self.emit_signal("on_TimeLabel_pressed", y)

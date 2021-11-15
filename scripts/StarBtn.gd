extends TextureRect

signal mouse_hover(value)
signal mouse_out(value)
signal mouse_pressed(value, is_pressed)
signal starBtn_pressed(toggle, value)


export var star_selected : Texture 
export var star_unselected : Texture 
export var star_hover : Texture 

export(int) var value
export var is_pressed: bool = false setget set_is_pressed


func set_is_pressed(value:bool) ->void:
	if value:
		texture = star_selected
		is_pressed = true
	else:
		texture = star_unselected
		is_pressed = false


func toggle_is_pressed() -> bool:
	if is_pressed:
		set_is_pressed(false)
		return false
	else:
		set_is_pressed(true)
		return true


func overflew(val:bool) ->void:
	if val == true and is_pressed == false:
		texture = star_hover
	elif val == false and is_pressed == false:
		texture = star_unselected
	elif val == false and is_pressed == true:
		texture = star_selected

		

func _on_StarBtn_toggled(button_pressed):
	emit_signal("starBtn_pressed", button_pressed, value)


func _on_StarBtn_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		toggle_is_pressed()
		emit_signal("mouse_pressed", value, is_pressed)


func _on_StarBtn_mouse_entered():
	texture = star_hover
	emit_signal("mouse_hover", value)


func _on_StarBtn_mouse_exited():
	if is_pressed:
		texture = star_selected
	else:
		texture = star_unselected
	emit_signal("mouse_out", value)

extends HBoxContainer


onready var timer_container : VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/TimeContainer
onready var calendar_array := $VBoxContainer/ScrollContainer/VBoxContainer/CalendarArray


func _ready() -> void:
	for child in timer_container.get_children():
		child.connect("time_button_pressed", calendar_array, "set_all_the_line")



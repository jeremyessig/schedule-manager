extends HBoxContainer

onready var timer_container : VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/TimeContainer
onready var calendar_array := $VBoxContainer/ScrollContainer/VBoxContainer/CalendarArray
onready var days_container : HBoxContainer = $VBoxContainer/DaysContainer


func _ready() -> void:
	for child in timer_container.get_children():
		child.connect("time_button_pressed", calendar_array, "set_all_the_line")
		
	for day in days_container.get_children():
		if day is Button:
			day.connect("day_button_pressed", calendar_array, "set_all_the_column")


	

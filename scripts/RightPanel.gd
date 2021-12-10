extends HBoxContainer

onready var timer_container : VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/TimeContainer
onready var calendar_array := $VBoxContainer/ScrollContainer/VBoxContainer/CalendarArray
onready var days_container : HBoxContainer = $VBoxContainer/DaysContainer
onready var days_container_margin_right : MarginContainer = $VBoxContainer/DaysContainer/MarginRight


func _ready() -> void:
	Signals.connect("png_export_started", self, "_on_png_export_started")
	Signals.connect("png_export_ended", self, "_on_png_export_ended")
	
	for child in timer_container.get_children():
		child.connect("time_button_pressed", calendar_array, "set_all_the_line")
		
	for day in days_container.get_children():
		if day is Button:
			day.connect("day_button_pressed", calendar_array, "set_all_the_column")


func _on_png_export_started():
	days_container_margin_right.hide()
	
func _on_png_export_ended():
	days_container_margin_right.show()

extends HBoxContainer
var time_button := preload("res://tscn/prefabs/TimeButton.tscn")

onready var timer_container : VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/TimeContainer
onready var calendar_array := $VBoxContainer/ScrollContainer/VBoxContainer/CalendarArray
onready var days_container : HBoxContainer = $VBoxContainer/DaysContainer
onready var days_container_margin_right : MarginContainer = $VBoxContainer/DaysContainer/MarginRight


func _ready() -> void:
	Signals.connect("png_export_started", self, "_on_png_export_started")
	Signals.connect("png_export_ended", self, "_on_png_export_ended")
	_init_time_buttons()


func _init_time_buttons():
	for node in range(29):
		var tmp = time_button.instance()
		timer_container.add_child(tmp)


func _on_png_export_started():
	days_container_margin_right.hide()
	
func _on_png_export_ended():
	days_container_margin_right.show()

extends HBoxContainer

var location_A: String setget set_location_A, get_location_A
var location_B: String setget set_location_B, get_location_B
var time : int setget set_time, get_time

onready var location_A_line_edit : LineEdit = $LocationALineEdit
onready var location_B_line_edit : LineEdit = $LocationBLineEdit
onready var hour_line_edit : LineEdit = $TimeContainer/HourLineEdit
onready var minute_line_edit : LineEdit = $TimeContainer/MinuteLineEdit


func set_location_A(value:String) ->void:
	location_A = value
	_refresh_GUI()

func get_location_A() ->String:
	return location_A

func set_location_B(value:String) ->void:
	location_B = value
	_refresh_GUI()

func get_location_B() ->String:
	return location_B

func set_time(value:int) ->void:
	time = value
	_refresh_GUI()
	
func get_time() ->int:
	return time

func _ready():
	add_to_database()


func init_values(data:Dictionary) ->void:
	location_A = data["location_A"]
	location_B = data["location_B"]
	time = data["time"]
	_refresh_GUI()


func delete() ->void:
	self.queue_free()


func add_to_database() ->void:
	Global.add_to_routes_database(location_A, location_B, time)


func _refresh_GUI() ->void:
	var t = Time.new()
	print(location_A_line_edit)
	location_A_line_edit.text = location_A
	location_B_line_edit.text = location_B
	var time_table = t.get_time_24h_StringArray(time)
	hour_line_edit.text = time_table[0]
	minute_line_edit.text = time_table[1]




func _on_DeleteBtn_pressed():
	delete()

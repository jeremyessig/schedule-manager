extends Control

var route = load("res://tscn/prefabs/Route.tscn")
var AddNewRouteBtn_pressed : bool = false

onready var list_of_routes : VBoxContainer = $Panel/VBoxContainer/Body/BodyVContainer/ListOfRoutesPanel/ListOfRoutes
onready var new_location_A_OptionButton : OptionButton = $Panel/VBoxContainer/Body/BodyVContainer/NewConnectionContainer/NewLocationAOptionButton
onready var new_location_B_OptionButton : OptionButton = $Panel/VBoxContainer/Body/BodyVContainer/NewConnectionContainer/NewLocationBOptionButton
onready var new_hour_OptionButton : OptionButton = $Panel/VBoxContainer/Body/BodyVContainer/NewConnectionContainer/TimeContainer/NewHourTimeOptionButton
onready var new_minute_OptionButton : OptionButton = $Panel/VBoxContainer/Body/BodyVContainer/NewConnectionContainer/TimeContainer/NewMinuteTimeOptionButton
onready var no_route_label : Label = $Panel/VBoxContainer/Body/BodyVContainer/ListOfRoutesPanel/ListOfRoutes/NoRouteLabel

func _ready():
	Signals.connect("locations_database_updated", self, "refresh_GUI")
	Signals.connect("database_reseted", self, "reset_GUI")
	Signals.connect("locations_database_updated", self, "reset_inputs")
	Signals.connect("locations_database_updated", self, "load_res")
	Signals.connect("route_deleted", self, "_set_NoRouteLabel")



##________________________ Create a new route_____________________________
func add_route(data:Dictionary) ->void:
	no_route_label.hide()
	var new_route = route.instance()
	list_of_routes.add_child(new_route)
	new_route.init_values(data)
	AddNewRouteBtn_pressed = false


func get_data_from_user() ->Dictionary:
	var data :Dictionary= {} 
	data["location_A"] = Global.get_item_string(new_location_A_OptionButton)
	data["location_B"] = Global.get_item_string(new_location_B_OptionButton)
	data["time"] = get_time_from_user()
	return data


func get_time_from_user() -> int:
	var time_table : Array
	time_table.append(Global.get_item_string(new_hour_OptionButton))
	time_table.append(Global.get_item_string(new_minute_OptionButton))
	var time = Time.new()
	return time.get_minutes(time_table)


func are_fields_empty() ->bool:
	if new_location_A_OptionButton.get_item_count() == 0:
		return true
	if new_location_B_OptionButton.get_item_count() == 0:
		return true
	if new_hour_OptionButton.get_item_count() == 0:
		return true
	if new_minute_OptionButton.get_item_count() == 0:
		return true
	return false

func add_to_database(data) ->void:
	Global.add_to_routes_database(data["location_A"], data["location_B"], data["time"])
#	print_debug(Global.routes_database)


func load_res() ->void:
	if AddNewRouteBtn_pressed:
		return
	for route in Global.routes_database:
		var data :Dictionary
		data["location_A"] = route[0]
		data["location_B"] = route[1]
		data["time"] = route[2]
		add_route(data)


func is_new_route_valid(data_from_user:Dictionary) ->bool:
	if are_fields_empty():
		print("Error: Fields are empty")
		return false
	if data_from_user["location_A"] == data_from_user["location_B"]:
		return false
	if Global.is_in_routes_database(data_from_user["location_A"], data_from_user["location_B"]):
		return false
	if data_from_user["time"] == 0:
		return false
	return true
#___________________ GUI____________________________

func refresh_GUI() ->void:
	Global.update_option_button(new_location_A_OptionButton, Global.locations_database)
	Global.update_option_button(new_location_B_OptionButton, Global.locations_database)


func _set_NoRouteLabel() ->void:
	print(list_of_routes.get_child_count())
	if list_of_routes.get_child_count() == 2:
		no_route_label.show()

func reset_GUI(database_name:String="") ->void:
	clear_inputs()
	for child in list_of_routes.get_children():
		if child is HBoxContainer:
			child.queue_free()
	no_route_label.show()


func clear_inputs():
	new_location_A_OptionButton.clear()
	new_location_B_OptionButton.clear()
	reset_inputs()
	

func reset_inputs() ->void:
	if new_location_A_OptionButton.get_item_count() != 0:
		new_location_A_OptionButton.select(0)
	if new_location_B_OptionButton.get_item_count() != 0:
		new_location_B_OptionButton.select(0)
	if new_hour_OptionButton.get_item_count() != 0:
		new_hour_OptionButton.select(0)
	if new_minute_OptionButton.get_item_count() != 0:
		new_minute_OptionButton.select(0)


##_________________ Methodes connectees________________________

func _on_CloseBtn_pressed():
	hide()


func _on_AddNewRouteBtn_pressed():
	var data_from_user :Dictionary = get_data_from_user()
	if !is_new_route_valid(data_from_user):
		return
	AddNewRouteBtn_pressed = true
	add_to_database(data_from_user)
	add_route(data_from_user)

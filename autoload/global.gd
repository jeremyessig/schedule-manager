extends Node

var right_panel : HBoxContainer
var left_panel : Panel
var new_lesson_button : Button
var new_subject_button : Button
var alert_dialog : Control
var calendar_array : HBoxContainer
var new_subject_dialog : Control
const weekday : Array = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]

var locations_database: Array
var subjects_database : Array
var lessons_database : Dictionary

var settings: Dictionary = {
	"card_index_top": false,
}

##__________ Gestion des etablissements
func set_locations_database(value) ->void:
	locations_database = value
	locations_database.sort()
	Signals.emit_signal("locations_database_updated")


func get_locations_database() ->Array:
	return locations_database
	
	
func add_to_locations_database(value:String) ->void:
	locations_database.append(value)
	locations_database.sort()
	Signals.emit_signal("locations_database_updated")


func remove_from_locations_database(location:String) ->void:
	var index : int = locations_database.find(location)
	locations_database.remove(index)
	Signals.emit_signal("locations_database_updated")



##__________ Gestion des cours
func set_lessons_database(value) ->void:
	lessons_database = value
	Signals.emit_signal("lessons_database_updated")


func get_lessons_database() ->Dictionary:
	return lessons_database


func add_to_lessons_database(key:String, value:Array) ->void:
	lessons_database[key] = value
	var keys_table = lessons_database.keys()
	keys_table.sort()
	var tmp : Dictionary
	for i in keys_table:
		tmp[i] = lessons_database[i]
	lessons_database = tmp
	Signals.emit_signal("lessons_database_updated")


func remove_from_lessons_database(key:String) ->void:
	lessons_database.erase(key)
	Signals.emit_signal("lessons_database_updated")
		


##__________ Gestion des sujets
func set_subjects_database(value) ->void:
	subjects_database = value
	subjects_database.sort()
	Signals.emit_signal("subjects_database_updated")

func get_subjects_database() ->Array:
	return subjects_database

func add_to_subjects_database(value:String) ->void:
	subjects_database.append(value)
	subjects_database.sort()
	Signals.emit_signal("subjects_database_updated")

	
func remove_from_subjects_database(subject:String) ->void:
	var index = subjects_database.find(subject)
	subjects_database.remove(index)
	Signals.emit_signal("subjects_database_updated")



##________________________

func get_weekday() ->Array:
	return weekday.duplicate()




func _ready() -> void:
	_connect_signals()
	var root = get_tree().get_root()
	right_panel = find_node_by_name(root, "RightPanel")
	new_lesson_button = find_node_by_name(root, "NewLessonButton")
	new_subject_button = find_node_by_name(root, "NewSubjectButton")
	alert_dialog = find_node_by_name(root, "AlertDialog")
	left_panel = find_node_by_name(root, "LeftPanel")
	calendar_array = find_node_by_name(root, "CalendarArray")
	new_subject_dialog = find_node_by_name(root, "NewSubjectDialog")


func _connect_signals() ->void:
	Signals.connect("program_reseted", self, "reset_databases")


## Gestion des bases de donnees
func reset_databases() -> void:
	subjects_database.clear()
	Signals.emit_signal("database_reseted", "subjects_database")
	lessons_database.clear()
	Signals.emit_signal("database_reseted", "lessons_database")
	locations_database.clear()
	Signals.emit_signal("database_reseted", "locations_database")
	

## Met a jours les optionButton listant les differentes matieres
func update_option_button(button:OptionButton, database, subject: String = "")->void:
	button.clear()
	if database is Array:
		for i in database:
			button.add_item(i)
	if database is Dictionary:
		if subject == "":
			for k in database:
				var value = database[k]
				button.add_item(value[0])
		else:
			for k in database:
				var value = database[k]
				if subject == value[1]:
					button.add_item(value[0])			


func reparent_node(parent: Node, child: Node, target:Node) ->void:
	parent.remove_child(child)
	target.add_child(child)
	if settings["card_index_top"]:
		target.move_child(child, 0)
	child.set_owner(target)


func get_item_string(node:OptionButton) ->String:
	var item_id = node.get_selected_id()
	var item_index = node.get_item_index(item_id)
	if item_index == -1:
		print_debug("Error: %s has no value" %node.name)
		return ""
	var string = node.get_item_text(item_index)
	return string


static func find_node_by_name(root, node_name:String) ->Node:
	if root.get_name() == node_name:
		return root
	for child in root.get_children():
		if child.get_name() == node_name:
			return child
		var found = find_node_by_name(child, node_name)
		if found:
			return found	
	return null

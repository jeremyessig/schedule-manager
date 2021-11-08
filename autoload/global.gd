extends Node

var right_panel : HBoxContainer
var left_panel : Panel
var new_lesson_button : Button
var new_subject_button : Button
var alert_dialog : Control
var calendar_array : HBoxContainer
var new_subject_dialog : Control

var subjects_database : Array
var lessons_database : Dictionary

func _ready() -> void:
	var root = get_tree().get_root()
	right_panel = find_node_by_name(root, "RightPanel")
	new_lesson_button = find_node_by_name(root, "NewLessonButton")
	new_subject_button = find_node_by_name(root, "NewSubjectButton")
	alert_dialog = find_node_by_name(root, "AlertDialog")
	left_panel = find_node_by_name(root, "LeftPanel")
	calendar_array = find_node_by_name(root, "CalendarArray")
	new_subject_dialog = find_node_by_name(root, "NewSubjectDialog")
	

## Met a jours les optionButton listant les differentes matieres
func update_option_button(button:OptionButton, database)->void:
	button.clear()
	if database is Array:
		for i in database:
			button.add_item(i)
	if database is Dictionary:
		for k in database:
			var value = database[k]
			button.add_item(value[0])


func reparent_node(parent: Node, source: Node, target:Node) ->void:
	parent.remove_child(source)
	target.add_child(source)
	source.set_owner(target)


func get_item_string(node:OptionButton) ->String:
	var item_id = node.get_selected_id()
	var item_index = node.get_item_index(item_id)
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

extends Node


func _ready():
	pass

func find_node_by_name(root, node_name:String) ->Node:
	if root.get_name() == node_name:
		return root
	for child in root.get_children():
		if child.get_name() == node_name:
			return child
		var found = find_node_by_name(child, node_name)
		if found:
			return found	
	return null

extends HBoxContainer

#29 noeuds
#onready var temp_node := $Temp

var empty_cell = preload("res://tscn/CellButton.tscn")
var lesson_cell = preload("res://tscn/LessonCellButton.tscn")

func _ready() -> void:
	_init_calendar_grid()
	Signals.connect("removing_lesson_from_calendar", self, "remove_lesson")


func _init_calendar_grid() ->void:
	for column in self.get_children():
		if not column is VBoxContainer:
			return
		_add_empty_cells(29, column, column.get_index())


func _add_empty_cells(number:int, column:Node, x:int) ->void:
	for _node in range(number):
		var tmp = empty_cell.instance()
		column.add_child(tmp)
		tmp.add_coord_to_cell(x,tmp.get_index())



func remove_lesson(pos: Vector2, size:int, id:String) ->void:
	for column in self.get_children():
		if column.get_index() == pos.x:
			for line in column.get_children():
				if line.position.y == pos.y:
					var i := 0
					var new_cells := []
					while i < size:
						var tmp = empty_cell.instance()
						tmp.add_coord_to_cell(pos.x, pos.y + i)
						new_cells.append(tmp)
						var index = line.get_position_in_parent()
						column.add_child_below_node(line, tmp)
						column.move_child(tmp, index)
						i += 1
					line.queue_free()
					Signals.emit_signal("lesson_removed_from_calendar", id)
					for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
						lesson_card.set_conflicts()
					



func add_lesson(node_path:NodePath) ->void:
	var card = get_node(node_path)
	for column in self.get_children():
		if column.get_index() == card.position.x: ## cherche la bonne colonne
			var i:= 0
			var node_to_replace = []
			while i < card.size:
				var node : Node 
				for child in column.get_children():
					if child.position.y == card.position.y + i:
						node = child
				node_to_replace.append(node)
				if node == null:
					Signals.emit_signal("error_emitted", "FilledCell", null)
					card.is_displayed = false
					return
				i += node.size
			for node in node_to_replace:
				if not node.is_empty:
					Signals.emit_signal("error_emitted", "FilledCell", null)
					card.is_displayed = false
					return
			var tmp = lesson_cell.instance()
			tmp.init_cell(card.position.x, card.position.y, card.size, card.get_data())
			card.connect("lesson_cell_updated", tmp, "update_cell")
			
			## supprime les anciennes cellules vides
			for node in node_to_replace:
				node.queue_free()

			var node_index : int
			for child in column.get_children():
				if child.position.y + child.size <= card.position.y:
					node_index += 1
			column.add_child(tmp)
			column.move_child(tmp, node_index)
			card.is_displayed = true
			for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
				lesson_card.set_conflicts()
			Signals.emit_signal("lesson_added_to_calendar", card.get_data())

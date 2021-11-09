extends Node
class_name Sort

#static func by_last_edit(table:Array, invert: bool = false) -> Array:
#
#	return []
#
#func _sort_by_datetime(table:Array, value):
#	for node in table:
#		if node.save_date["edited"]["year"]: 

static func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false
	

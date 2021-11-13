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


static func by_rating(table:Array, max_rating:int, tmp:Array = [], count:int = 0):
	for node in table:
		if node.rating == count:
			tmp.append(node)
			table.erase(table.find(node))
	if count < max_rating:
		count += 1
		by_rating(table, max_rating, tmp, count)
	return tmp


#static func by_rating(table:Array, max_rating:int, tmp:Array = []):
#	for node in table:
#		if node.rating == max_rating:
#			tmp.append(node)
#			table.erase(table.find(node))
#	if max_rating >= 0:
#		max_rating -= 1
#		by_rating(table, max_rating, tmp)
#	return tmp

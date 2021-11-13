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


static func by_rating(table:Array, max_rating:int, tmp:Array = [], count:int = 0) ->Array:
	for node in table:
		if node.rating == count:
			tmp.append(node)
			table.erase(table.find(node))
	if count < max_rating:
		count += 1
		by_rating(table, max_rating, tmp, count)
	return tmp

	
static func by_subjects(table:Array, subjects_list:Array, invert:bool=false) ->Array:
	subjects_list.sort()
	if invert:
		subjects_list.invert()
	var tmp:Array
	for subject in subjects_list:
		for node in table:
			if subject == node.subject:
				tmp.append(node)
				table.erase(table.find(node))
	return tmp


static func by_days(table:Array, weekday_list:Array, invert:bool = false) ->Array:
	if invert:
		weekday_list.invert()
	var tmp: Array
	for weekday in weekday_list:
		for node in table:
			if weekday == node.schedule[1]:
				tmp.append(node)
				table.erase(table.find(node))
	return tmp
	
	
	
	
	
	
	
	

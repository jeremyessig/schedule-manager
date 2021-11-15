extends Node
class_name ID

const day_to_letter_table: Array = [["Lundi", "aaa"], ["Mardi", "bbb"], ["Mercredi", "ccc"],["Jeudi", "ddd"],["Vendredi", "eee"],["Samedi", "fff"]]
const td_cm_table: Dictionary = {"Cours Magistral":"cm", "Travaux Dirigés":"td"}





func generate(subject: String, lesson:String, type:String, day:String, hour, minute, room) ->String:
	var new_id :String = lesson + subject + _abbreviate_cm_td(type) + _attribut_letter_to_day(day) + str(hour) + str(minute) + str(room)
	new_id = new_id.to_lower()
	new_id = new_id.replace(" ", "")
	new_id = new_id.replace("'", "")
	new_id = new_id.replace(":","")
	new_id = new_id.replace(".","")
	new_id = new_id.replace(",","")
	new_id = new_id.replace("_","")
	new_id = new_id.replace("-","")
	new_id = new_id.replace("/","")
	new_id = new_id.replace("é","e")
	new_id = new_id.replace("è","e")
	new_id = new_id.replace("à","a")
	new_id = new_id.replace("(","")
	new_id = new_id.replace(")","")
	return new_id



func exists(id:String) ->bool:
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		if card.id == id:
			return true
	return false
	





##_________________Methodes privees_________________________
func _attribut_letter_to_day(day: String) ->String:
	for letter in day_to_letter_table:
		if letter[0] == day:
			return letter[1]
	return day


func _abbreviate_cm_td(type:String) ->String:
	var abb :String = td_cm_table[type]
	return abb

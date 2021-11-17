extends Node
class_name ID

const day_to_letter_table: Array = [["Lundi", "aaa"], ["Mardi", "bbb"], ["Mercredi", "ccc"],["Jeudi", "ddd"],["Vendredi", "eee"],["Samedi", "fff"]]
const td_cm_table: Dictionary = {"Cours Magistral":"cm", "Travaux Dirigés":"td"}





func generate(subject: String, lesson:String, type:String, day:String, time:String, location:String, room) ->String:
	var new_id :String = lesson + subject + _abbreviate_cm_td(type) + _attribut_letter_to_day(day) + time +location +str(room)
	new_id = standardize_string(new_id)
	print("new_id: %s" %new_id)
	return new_id



func exists(id:String) ->bool:
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		if card.id == id:
			return true
	return false
	

static func standardize_string(string:String) ->String:
	string = string.to_lower()
	string = string.replace(" ", "")
	string = string.replace("'", "")
	string = string.replace(":","")
	string = string.replace(".","")
	string = string.replace(",","")
	string = string.replace("_","")
	string = string.replace("-","")
	string = string.replace("/","")
	string = string.replace("é","e")
	string = string.replace("û","u")
	string = string.replace("ù","u")
	string = string.replace("ë","e")
	string = string.replace("è","e")
	string = string.replace("ê","e")
	string = string.replace("à","a")
	string = string.replace("(","")
	string = string.replace(")","")
	return string



##_________________Methodes privees_________________________
func _attribut_letter_to_day(day: String) ->String:
	for letter in day_to_letter_table:
		if letter[0] == day:
			return letter[1]
	return day


func _abbreviate_cm_td(type:String) ->String:
	var abb :String = td_cm_table[type]
	return abb

## Verifie si des insultes ont ete ajoutees dans les champs de saisie

extends Node
class_name IsSafe

const banned_words :Array = ["pute", "put", "salope", "connard", "conard", "conar", "encule", "enculee", "salaud", "salau", "merde", "merd",
							"m3rd3", "merd3", "m3rd", "cul", "cu", "cule", "fuck", "fucking", "fuckin", "bitch", "sal0pe", "sal0p", "chier",
							"chie", "chiee", "chies", "chiees", "put3"]


func word(word:String) ->bool:
	word = ID.standardize_string(word)
	if banned_words.find(word) != -1:
		Signals.emit_signal("error_emitted", "BannedWord", null)
		return false
	return true
	

func string(string:String) ->bool:
	var words_table = string.split(" ")
	for word in words_table:
		if not word(word):
			return false
	return true

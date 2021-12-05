extends Node


var card_index_top := false setget set_card_index_top
var autosave := false

func set_card_index_top(value):
	card_index_top = value

func set_autosave(value):
	autosave = value




func get_data() -> Dictionary:
	var data := {
		"card_index_top":card_index_top,
		"autosave": autosave
	}
	return data


func set_data(data:Dictionary) -> void:
	set_card_index_top(data["card_index_top"])
	set_autosave(data["autosave"])

extends Node


var card_index_top := false setget set_card_index_top
var autosave := false setget set_autosave
var autosave_wait_time :int= 300 setget set_autosave_wait_time

func set_card_index_top(value):
	card_index_top = value

func set_autosave(value):
	autosave = value

func set_autosave_wait_time(value:int) ->void:
	autosave_wait_time = clamp(value, 300, 1800) ## Maximum de 30 min
	print(autosave_wait_time)



func get_data() -> Dictionary:
	var data := {
		"card_index_top":card_index_top,
		"autosave": autosave,
		"autosave_wait_time": autosave_wait_time
	}
	return data


func set_data(data:Dictionary) -> void:
	set_card_index_top(data["card_index_top"])
	set_autosave(data["autosave"])
	set_autosave_wait_time(data["autosave_wait_time"])

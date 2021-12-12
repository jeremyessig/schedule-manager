extends Node

var is_first_time :bool = true
var card_index_top := false setget set_card_index_top
var autosave := false setget set_autosave
var autosave_wait_time :int= 300 setget set_autosave_wait_time
var CM_default_duration : int = 0 setget set_CM_default_duration
var TD_default_duration : int = 0 setget set_TD_default_duration
var start_window_size : Vector2 = Vector2(1280,720) setget set_start_window_size
var tutorial_popup : bool = true setget set_tutorial_popup
var last_res_file_loaded : String setget set_last_res_file_loaded
var TD_is_same_color_as_CM : bool = true setget set_TD_is_same_color_as_CM
#var number_of_columns : int = 1 setget set_number_of_columns

func set_card_index_top(value:bool) ->void:
	card_index_top = value

func set_autosave(value:bool) ->void:
	autosave = value

func set_autosave_wait_time(value:int) ->void:
	autosave_wait_time = clamp(value, 300, 1800) ## Maximum de 30 min
	print(autosave_wait_time)
	
func set_CM_default_duration(value:int) ->void:
	CM_default_duration = value
	
func set_TD_default_duration(value:int) ->void:
	TD_default_duration = value

func set_start_window_size(value:Vector2) ->void:
	start_window_size = value
	
func set_tutorial_popup(value:bool) ->void:
	tutorial_popup = value
	
func set_last_res_file_loaded(value:String) ->void:
	last_res_file_loaded = value
	
func set_TD_is_same_color_as_CM(value:bool) ->void:
	TD_is_same_color_as_CM = value
	
#func set_number_of_columns(value:int) ->void:
#	number_of_columns = value
#	Signals.emit_signal("preference_number_of_columns_setted")



func get_data() -> Dictionary:
	var data := {
		"card_index_top":card_index_top,
		"autosave": autosave,
		"autosave_wait_time": autosave_wait_time,
		"CM_default_duration": CM_default_duration,
		"TD_default_duration": TD_default_duration,
		"start_window_size": var2str(Vector2(start_window_size)),
		"tutorial_popup": tutorial_popup,
		"last_res_file_loaded": last_res_file_loaded,
		"TD_is_same_color_as_CM" : TD_is_same_color_as_CM
#		"number_of_columns" : number_of_columns
	}
	return data


func set_data(data:Dictionary) -> void:
	set_card_index_top(data["card_index_top"])
	set_autosave(data["autosave"])
	set_autosave_wait_time(data["autosave_wait_time"])
	set_CM_default_duration(data["CM_default_duration"])
	set_TD_default_duration(data["TD_default_duration"])
	set_start_window_size(str2var(data["start_window_size"]) as Vector2)
	set_tutorial_popup(data["tutorial_popup"])
	set_last_res_file_loaded(data["last_res_file_loaded"])
	set_TD_is_same_color_as_CM(data["TD_is_same_color_as_CM"])
#	set_number_of_columns(data["number_of_columns"])

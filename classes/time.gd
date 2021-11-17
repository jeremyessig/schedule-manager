class_name Time

const minutes_in_day : int = 1440

	
func get_minutes(time:Array) ->int:
	var hour = time[0]
	var minute = time[1]
	return int(hour) * 60 + int(minute)

## inserer une string "1h30"
func get_minutes_from_str(time:String) ->int:
	var time_table:Array 
	if "h" in time:
		time_table = time.split("h")
	if ":" in time:
		time_table= time.split(":")
	return get_minutes(time_table)

	
func get_time_24h(minutes: int) -> Array:
	var hours := minutes / 60
	minutes = minutes%60
	return [hours, minutes]


func get_time_24h_str(minutes:int, separator:String=":") -> String:
	var time := get_time_24h(minutes)
	if time[1] <10:
		time[1] = "0" + str(time[1])
	return str(time[0]) + separator + str(time[1])

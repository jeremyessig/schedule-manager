class_name Time

const minutes_in_day : int = 1440

	
static func get_minutes(time:Array) ->int:
	var hour = time[0]
	var minute = time[1]
	return int(hour) * 60 + int(minute)


## inserer une string "1h30" en parametre
static func get_minutes_from_str(time:String) ->int:
	var time_table:Array 
	if "h" in time:
		time_table = time.split("h")
	if ":" in time:
		time_table= time.split(":")
	return get_minutes(time_table)


static func get_time_24h(minutes: int) -> Array:
	var hours := minutes / 60
	minutes = minutes%60
	return [hours, minutes]


## Retourne un Array de String [7, 00]
static func get_time_24h_StringArray(minutes:int) -> Array:
	var time := get_time_24h(minutes)
	time[0] = str(time[0])
	if time[1] <10:
		time[1] = "0" + str(time[1])
	time[1] = str(time[1]) 
	return time


## Retourne un Array de String [07, 00]
static func get_time_00h00_StringArray(minutes:int) ->Array:
	var time :Array= get_time_24h_StringArray(minutes)
	if int(time[0]) < 10:
		time[0] = "0" + time[0]
	return time


## Retourne un format de type 7:00
static func get_time_24h_str(minutes:int, separator:String=":") -> String:
	var time := get_time_24h_StringArray(minutes)
	return time[0] + separator + time[1]


## Retourne un format de type 07:00
static func get_time_00h00_str(minutes:int, separator:String=":") -> String:
	var time := get_time_00h00_StringArray(minutes)
	return time[0] + separator + time[1]


static func get_time_csv_format(minutes:int) ->String:
	var time: String
	if minutes < 720: ## < que 12h ==> AM
		time = get_time_00h00_str(minutes) + " AM"
	elif minutes >= 720 and minutes < 780: ## minutes >= 12h00 et minutes < 13h00
		time = get_time_00h00_str(minutes) + " PM"
	else:
		minutes = minutes - 720
		time = get_time_00h00_str(minutes) + " PM"		
	return time

extends Node
class_name Conflict

## Verifie si il y a un clonflit avec un autre cours
## Calcule si les deux paires de chiffres ont des minutes de cours en commun
static func get_number_of_minutes_in_common(A_start:int, A_end:int, B_start:int, B_end:int) ->int:
	var start = max(A_start, B_start)
	var end = min(A_end, B_end)
	return end-start+1


## Verifie si le nombre de minutes entre les 2 cours est superieur a 1 
static func is_in_conflict_with(A:Dictionary, B:Dictionary, travel_time:int) ->bool:
	if B["day"] != A["day"]:
		return false
	var minutes: int = get_number_of_minutes_in_common(A["start"], A["end"], B["start"], B["end"])
	minutes += travel_time
	if minutes > 1:
		return true
	return false	

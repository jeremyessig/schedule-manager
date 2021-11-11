## Pour ajouter l'emploi du temps dans l'agenda, il faut absolument que l'utilisateur 
## selectionne un lundi comme premier jour des cours. S'il definit un autre jour comme
## jour de depart, tous les jours seront decales.

extends Control

signal open_exporting_csv_file_dialog

var calendar = preload("res://addons/calendar_button/class/Calendar.gd")

var start_date :Array = [] ## Premier lundi de la rentree des cours que l'utilisateur indique

onready var begining_week_line_edit : LineEdit = $Panel/VBoxContainer/Body/GridContainer/BeginingWeekLineEdit
onready var notification_label : Label = $Panel/VBoxContainer/Foot/VBoxContainer/NotificationLabel

## Recupere les lesson_card (is_displayed) qui sont dans l'emploi du temps  
func _get_nodes_in_schedule() -> Array:
	var array := []
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		if card.is_displayed:
			array.append(card) 
	return array


## Ajoute les dates et les heures dans l'attribut datetime de lesson_card
func _attribute_datetime_to_nodes(nodes:Array) ->void:
	for node in nodes:
		node.datetime.clear()
		_attribute_day(node)
		_attribute_time(node)
		print_debug(node.lesson, node.datetime)


## Additionne l'heure de debut et la duree pour obtenir l'heure de fin du cours
## Cette fonction est presque la meme que celle dans lesson_card ==> voir pour les fusionner
func _attribute_time(node:Node) ->void:
	var begining : String = _export_time(int(node.schedule[2]), int(node.schedule[3]))
	var hours = int(node.duration[0]) + int(node.schedule[2])
	var minutes = 30
	if int(node.duration[1]) + int(node.schedule[3]) >= 60:
		hours += 1
		minutes = 0
	if int(node.duration[1]) + int(node.schedule[3]) < 30:
		minutes = 0
	var end : String = _export_time(hours, minutes)
	
	node.datetime.append([begining, end])


## Transforme des heures et minutes sur 24h en temps sur 12H AM PM 
## Car le google agenda n'accepte que les heures sous format AM et PM
func _export_time(hours:int, minutes:int) ->String:
	var time : Array = [hours, minutes]
	if time[0] < 12: ## L'heure reste en AM (matin)
		var str_hour = export_int_str(time[0])
		var str_min = export_int_str(time[1])
		return str_hour + ":" + str_min + " AM"
	## L'heure bascule en PM 
	if time[0] == 12 and time[1] == 30:
		return "12:30 PM"
	var str_hour = export_int_str(time[0]-12)
	var str_min = export_int_str(time[1])
	return str_hour + ":" + str_min + " PM"


## Transforme un chiffre en une string minute ou heure en ajoutant un 0 
func export_int_str(integer:int) -> String:
	if integer < 10:
		return "0" + String(integer)
	else:
		return	String(integer)


## Recupere le jour de l'attribut schedule de lesson_card et le compare a une date reelle
func _attribute_day(node:Node) ->void:
	var weekday = node.schedule[1]
	var days_table = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
	var days_to_further = days_table.find(weekday)
	var date = change_to_next_day(int(start_date[0]), int(start_date[1]), int(start_date[2]), days_to_further)
	node.datetime.append(date)


## Permet d'avancer dans la semaine ==> retourne les dates en fonction des mois et annees bisextiles
func change_to_next_day(day:int, month:int, year:int, day_in_week:int) ->Array:
	day += day_in_week
	if day > calendar.get_days_in_month(month, year):
		var days_in_month = calendar.get_days_in_month(month, year)
		day = (day - days_in_month)
		if month == 12:
			month = 1
			year += 1
		else:
			month += 1 ## Met a jour au mois suivant 
		return [export_int_str(day), export_int_str(month), year]
	else:
		return [export_int_str(day), export_int_str(month), year]


## Permet de reculer dans la semaine ==> retourne les dates en fonction des mois et annees bisextiles
func change_to_previous_day(day:int, month:int, year:int, day_in_week:int) ->Array:
	day -= day_in_week
	if day < 1:
		var days_in_month = calendar.get_days_in_month(month -1, year)
		day = days_in_month + day
		if month == 1:
			month = 12
			year -= 1
		else:
			month -= 1
		return [export_int_str(day), export_int_str(month), year]
	else:
		return [export_int_str(day), export_int_str(month), year]


## Quelque soit le jour selectionne par l'utilisateur, le jour est initialise 
## au 1er lundi de la semaine selectionnee
func _init_week_to_monday(date_value) ->void:
	var day_name = Calendar.get_weekday_name(date_value[0], date_value[1], date_value[2])
	var days_table = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	var days_to_back = days_table.find(day_name)
	start_date = change_to_previous_day(start_date[0], start_date[1], start_date[2], days_to_back)
	print_debug(start_date)

##________________________________ GUI_________________________________

func _refresh_gui() ->void:
	begining_week_line_edit.text = "Semaine du lundi %s/%s/%s" %[start_date[0], start_date[1], start_date[2]]
	notification_label.text = ""



##_______________________ Methodes connectees___________________________

## Recupere la date selectionnee par l'utilisateur dans le calendrier. 
func _on_BeginingDateButton_date_selected(date_obj):
	start_date.clear()
	start_date.append(int(date_obj.date("DD")))
	start_date.append(int(date_obj.date("MM")))
	start_date.append(int(date_obj.date("YYYY")))
	_init_week_to_monday(start_date)
	_refresh_gui()


func _on_CancelButton_pressed():
	hide()


func _on_ExportButton_pressed():
	if start_date == []:
		notification_label.text = "Veuillez indiquer une date de début des cours"
		return
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		if card.is_displayed == true:
			var nodes : Array = _get_nodes_in_schedule()
			_attribute_datetime_to_nodes(nodes)
			emit_signal("open_exporting_csv_file_dialog") # -> Main
			return
	hide()
	Signals.emit_signal("error_emitted", "EmptySchedule", null)


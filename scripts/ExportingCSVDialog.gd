## Pour ajouter l'emploi du temps dans l'agenda, il faut absolument que l'utilisateur 
## selectionne un lundi comme premier jour des cours. S'il definit un autre jour comme
## jour de depart, tous les jours seront decaler. Trouver un moyen pour eviter ce bug... 

extends Control

signal open_exporting_csv_file_dialog

var calendar = preload("res://addons/calendar_button/class/Calendar.gd")

var start_date :Array = [] ## Premier lundi de la rentree des cours que l'utilisateur indique

onready var cancel_button : Button = $Panel/VBoxContainer/Foot/HBoxContainer/CancelButton
onready var day_option_button : OptionButton = $Panel/VBoxContainer/Body/GridContainer/HBoxContainer/DayOptionButton
onready var month_option_button : OptionButton = $Panel/VBoxContainer/Body/GridContainer/HBoxContainer/MonthOptionButton
onready var year_option_button : OptionButton = $Panel/VBoxContainer/Body/GridContainer/HBoxContainer/MonthOptionButton


func _ready():
	_add_item(day_option_button, 31, 1)
	_add_item(month_option_button, 12, 1)
	_add_item(year_option_button, 2020, 2040)
	

	
func _add_item(option_button: OptionButton, n:int, begining:int) ->void:	
	var i = begining
	while i <= n:
		var number 
		if i <= 9:
			number = "0"+str(i)
		else:
			number = str(i)
		option_button.add_item(number, i)
		i+= 1

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
	var date
	match weekday:
		"Lundi":
			node.datetime.append(start_date)

		"Mardi":
			date = change_to_next_day(start_date[0], start_date[1], start_date[2], 1)
			node.datetime.append(date)

		"Mercredi":
			date = change_to_next_day(start_date[0], start_date[1], start_date[2], 2)
			node.datetime.append(date)

		"Jeudi":
			date = change_to_next_day(start_date[0], start_date[1], start_date[2], 3)
			node.datetime.append(date)

		"Vendredi":
			date = change_to_next_day(start_date[0], start_date[1], start_date[2], 4)
			node.datetime.append(date)

		"Samedi":
			date = change_to_next_day(start_date[0], start_date[1], start_date[2], 5)
			node.datetime.append(date)


## Permet d'avancer dans la semaine ==> retourne les dates en fonction des mois et annees bisextiles
func change_to_next_day(day:int, month:int, year:int, day_in_week:int) ->Array:
	var selected_day = day
	selected_day += day_in_week
	if selected_day > calendar.get_days_in_month(month, year):
		day = 1 ## reinitialise au premier jour du mois
		month += 1 ## Met a jour au mois suivant 
		return [export_int_str(day), export_int_str(month), year]
	else:
		day = selected_day
		return [export_int_str(day), export_int_str(month), year]


## Recupere la date selectionnee par l'utilisateur dans le calendrier. 
func _on_BeginingDateButton_date_selected(date_obj):
	start_date.clear()
	start_date.append(int(date_obj.date("DD")))
	start_date.append(int(date_obj.date("MM")))
	start_date.append(int(date_obj.date("YYYY")))
	print(start_date)


func _on_CancelButton_pressed():
	hide()


func _on_ExportButton_pressed():
	var nodes : Array = _get_nodes_in_schedule()
	_attribute_datetime_to_nodes(nodes)
	emit_signal("open_exporting_csv_file_dialog") # -> Main

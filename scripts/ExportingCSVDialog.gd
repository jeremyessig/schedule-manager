## Pour ajouter l'emploi du temps dans l'agenda, il faut absolument que l'utilisateur 
## selectionne un lundi comme premier jour des cours. S'il definit un autre jour comme
## jour de depart, tous les jours seront decales.

extends Control

signal open_exporting_csv_file_dialog

var calendar = preload("res://addons/calendar_button/class/Calendar.gd")

var start_date :Array = [] ## Premier lundi de la rentree des cours que l'utilisateur indique

onready var begining_week_line_edit : LineEdit = $Panel/VBoxContainer/Body/VBoxContainer/GridContainer/BeginingWeekLineEdit
onready var notification_label : Label = $Panel/VBoxContainer/Body/VBoxContainer/NotificationLabel
onready var export_btn : Button = $Panel/VBoxContainer/Foot/HBoxContainer/ExportButton
onready var export_btn_disabled : Button = $Panel/VBoxContainer/Foot/HBoxContainer/ExportButtonDisabled

func _ready():
	Signals.connect("dialog_export_csv_shown", self, "_shown")
	
func _shown() ->void:
	_set_navigation_buttons()

## Ajoute les dates et les heures dans l'attribut datetime de lesson_card
func _attribute_datetime_to_nodes(nodes:Array) ->void:
	for node in nodes:
		node.csv_datetime.clear()
		_attribute_day(node)
		_attribute_time(node)


## Retourne l'heure de debut et de fin du cours en format anglais (AM/PM)
func _attribute_time(node:Node) ->void:
	var time := Time.new()
	var begining :String = time.get_time_csv_format(node.schedule["start"]) 
	var end : String = time.get_time_csv_format(node.schedule["end"])
	node.csv_datetime.append([begining, end])


## Transforme un chiffre en une string minute ou heure en ajoutant un 0 
func export_int_str(integer:int) -> String:
	if integer < 10:
		return "0" + String(integer)
	else:
		return	String(integer)


## Recupere le jour de l'attribut schedule de lesson_card et le compare a une date reelle
func _attribute_day(node:Node) ->void:
	var weekday = node.schedule["day"]
	var days_table = Global.get_weekday()
	var days_to_further = days_table.find(weekday)
	var date = change_to_next_day(int(start_date[0]), int(start_date[1]), int(start_date[2]), days_to_further)
	node.csv_datetime.append(date)


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

##________________________________ GUI_________________________________

func _refresh_gui() ->void:
	begining_week_line_edit.text = "Semaine du lundi %s/%s/%s" %[start_date[0], start_date[1], start_date[2]]
	notification_label.text = ""

func _set_navigation_buttons() ->void:
	if begining_week_line_edit.text == "Aucune date":
		export_btn.hide()
		export_btn_disabled.show()
		notification_label.text = "Veuillez entrer la date de début des cours"
		notification_label.set("custom_colors/font_color", "#cd1e1e")
		begining_week_line_edit.set("custom_colors/font_color_uneditable", "#7c7c7c")
	else:
		export_btn.show()
		export_btn_disabled.hide()
		notification_label.text =""
		begining_week_line_edit.set("custom_colors/font_color_uneditable", "#383838")


##_______________________ Methodes connectees___________________________

## Recupere la date selectionnee par l'utilisateur dans le calendrier. 
func _on_BeginingDateButton_date_selected(date_obj):
	start_date.clear()
	start_date.append(int(date_obj.date("DD")))
	start_date.append(int(date_obj.date("MM")))
	start_date.append(int(date_obj.date("YYYY")))
	_init_week_to_monday(start_date)
	_refresh_gui()
	_set_navigation_buttons()


func _on_CancelButton_pressed():
	hide()


func _on_ExportButton_pressed():
	if start_date == []:
		notification_label.text = "Veuillez indiquer une date de début des cours"
		return
	var displayed_cards = get_tree().get_nodes_in_group("lesson_cards_displayed")
	if displayed_cards.empty():
		Signals.emit_signal("error_emitted", "EmptySchedule", null)
		return
	_attribute_datetime_to_nodes(displayed_cards)
	emit_signal("open_exporting_csv_file_dialog")
	hide()


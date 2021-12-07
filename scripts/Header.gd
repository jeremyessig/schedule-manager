extends Panel

signal export_json_pressed
signal import_json_pressed
signal export_csv_pressed
signal about_pressed
signal open_save_pressed
#signal route_pressed
signal preferences_pressed

onready var file : MenuButton = $HBoxContainer/Toolbar/FileMenuButton
onready var database_menu : MenuButton = $HBoxContainer/Toolbar/DatabaseMenuButton
onready var help : MenuButton = $HBoxContainer/Toolbar/HelpMenuButton
onready var display_menu : MenuButton = $HBoxContainer/Toolbar/DisplayMenuButton
onready var settings_menu : MenuButton = $HBoxContainer/Toolbar/SettingsMenuButton

onready var notifications : Label = $HBoxContainer/Notifications
onready var notifications_player : AnimationPlayer = $NotificationsPlayer

func _ready() -> void:
	file.get_popup().connect("id_pressed", self, "_on_file_item_pressed")
	database_menu.get_popup().connect("id_pressed", self, "_on_database_item_pressed")
	help.get_popup().connect("id_pressed", self, "_on_help_item_pressed")
	display_menu.get_popup().connect("id_pressed", self, "_on_display_item_pressed")
	settings_menu.get_popup().connect("id_pressed", self, "_on_settings_item_pressed")
	Signals.connect("data_saved", self, "_on_play_notif_data_saved")

func _on_file_item_pressed(id)->void:
	match id:
		0:
			Signals.emit_signal("program_reseted")
		1:
			pass
			emit_signal("open_save_pressed")
		2:
			if Preferences.last_res_file_loaded == "":
				return
			SaveSystem.load_from_res(Preferences.last_res_file_loaded)
		3:
			SaveSystem.save_to_res()
		4:
			Signals.emit_signal("save_as_pressed")
		5:
			emit_signal("export_csv_pressed")

func _on_database_item_pressed(id)->void:
	match id:
		0:
			emit_signal("import_json_pressed")
		1:
			emit_signal("export_json_pressed")


func _on_display_item_pressed(id)->void:
	match id:
		0:
			Global.left_panel.sort_cards(false)
		1:
			Global.left_panel.sort_cards(true)
		2:
			Global.left_panel.sort_lessons_by_rating()
		3:
			Global.left_panel.sort_lessons_by_rating(true)
		4:
			Global.left_panel.sort_lessons_by_subjects()
		5:
			Global.left_panel.sort_lessons_by_subjects(true)
		6:
			Global.left_panel.sort_lessons_by_days()
		7:
			Global.left_panel.sort_lessons_by_days(true)

func _on_settings_item_pressed(id)->void:
	match id:
		0:
			emit_signal("preferences_pressed")
			Signals.emit_signal("preferences_shown")
		1:
#			emit_signal("route_pressed")
			Signals.emit_signal("dialog_route_shown")

func _on_help_item_pressed(id)->void:
	match id:
		0:
			OS.shell_open("https://sites.google.com/view/schedulemanager/wiki")
		1:
			OS.shell_open("https://www.youtube.com/watch?v=fEdwhnshL5o&list=PLDX0YQ47r7645ZCiJqngqBQlqfnBtDwxL&index=3")
		2:	
			OS.shell_open("mailto:schedulemanagerforuniversity@gmail.com")
		3:
			emit_signal("about_pressed")


func _on_play_notif_data_saved() ->void:
	notifications_player.play("saving")

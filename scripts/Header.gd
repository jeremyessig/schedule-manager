extends Panel

signal export_json_pressed
signal import_json_pressed
signal export_csv_pressed
signal about_pressed

onready var file : MenuButton = $HBoxContainer/Toolbar/FileMenuButton
onready var database_menu : MenuButton = $HBoxContainer/Toolbar/DatabaseMenuButton
onready var help : MenuButton = $HBoxContainer/Toolbar/HelpMenuButton

func _ready() -> void:
	file.get_popup().connect("id_pressed", self, "_on_file_item_pressed")
	database_menu.get_popup().connect("id_pressed", self, "_on_database_item_pressed")
	help.get_popup().connect("id_pressed", self, "_on_help_item_pressed")
	

func _on_file_item_pressed(id)->void:
	match id:
		0:
			Signals.emit_signal("program_reseted")
		4:
			emit_signal("export_csv_pressed")

func _on_database_item_pressed(id)->void:
	match id:
		0:
			emit_signal("import_json_pressed")
		1:
			emit_signal("export_json_pressed")

func _on_help_item_pressed(id)->void:
	match id:
		0:
			emit_signal("about_pressed")

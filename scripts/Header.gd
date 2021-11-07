extends Panel

signal export_json_pressed
signal import_json_pressed
signal export_csv_pressed

onready var file : MenuButton = $HBoxContainer/Toolbar/FileMenuButton

func _ready() -> void:
	file.get_popup().connect("id_pressed", self, "_on_file_item_pressed")
	

func _on_file_item_pressed(id)->void:
	match id:
		2:
			emit_signal("export_json_pressed")
		3:
			emit_signal("import_json_pressed")
		4:
			emit_signal("export_csv_pressed")

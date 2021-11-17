extends Control

onready var new_lesson_dialog := $NewLessonDialog
onready var new_subject_dialog := $NewSubjectDialog
onready var alert_dialog := $AlertDialog
onready var header : Panel = $App/Header
onready var export_database_dialog : FileDialog = $ExportDatabaseDialog
onready var import_dialog : FileDialog = $ImportDialog
onready var export_csv_file_dialog : FileDialog = $ExportDialogCSV
onready var exporting_csv_dialog: Control = $ExportingCSVDialog
onready var about_dialog : WindowDialog = $AboutDialog
onready var save_as_dialog : FileDialog = $SaveAsDialog
onready var open_save_dialog : FileDialog = $OpenSaveDialog


func _ready() -> void:
	var time = Time.new()
	var cours_debut = time.get_minutes_from_str("16:00")
	var cours_duree = time.get_minutes_from_str("1h30")
	var cours_fini = cours_debut + cours_duree
	print(time.get_time_24h_str(cours_fini, "h"))
	Global.new_subject_button.connect("pressed", self, "_show_new_subject_dialog")
	Global.new_lesson_button.connect("pressed", self, "_show_new_lesson_dialog")
	header.connect("export_json_pressed", self, "_open_export_dialog")
	header.connect("import_json_pressed", self, "_open_import_dialog")
	header.connect("export_csv_pressed", self, "_open_export_csv_dialog")
	header.connect("about_pressed", self, "_open_about_dialog")
	Signals.connect("save_as_pressed", self, "_open_save_as_dialog")
	header.connect("open_save_pressed", self, "_open_open_save_dialog")
	
	
func _unhandled_input(event):
	if event.is_action_pressed("save"):
		SaveSystem.save_to_res()
	if event.is_action_pressed("open_saves"):
		open_save_dialog.popup_centered()

#________Methode d'affichage des dialogs_____________
func _show_new_lesson_dialog() ->void:
	new_lesson_dialog.check_subject_lesson_database()
	new_lesson_dialog.reset_default_GUI()
	new_lesson_dialog.show()

func _show_new_subject_dialog() ->void:
	new_subject_dialog.show()
	

func _open_export_dialog() -> void:
	export_database_dialog.popup_centered()

func _open_import_dialog() -> void:
	import_dialog.popup_centered()
	
func _open_export_csv_dialog() ->void:
	exporting_csv_dialog.show()

func _open_about_dialog() ->void:
	about_dialog.popup_centered()
	
func _open_save_as_dialog() ->void:
	save_as_dialog.popup_centered()

func _open_open_save_dialog() ->void:
	open_save_dialog.popup_centered()


func _on_FileDialog_file_selected(path):
	SaveSystem.export_to_JSON(path)


func _on_ImportDialog_file_selected(path):
	SaveSystem.import_from_JSON(path)


## Lance l'exportation en CSV
func _on_ExportDialogCSV_file_selected(path):
	SaveSystem.export_to_csv(path)
	export_csv_file_dialog.hide()

##Affiche le gestionnaire de fichier pour exporter en csv
func _on_ExportingCSVDialog_open_exporting_csv_file_dialog():
	export_csv_file_dialog.popup_centered()


func _on_SaveAsDialog_file_selected(path):
	SaveSystem.save_to_res(path)


func _on_OpenSaveDialog_file_selected(path):
	SaveSystem.load_from_res(path)

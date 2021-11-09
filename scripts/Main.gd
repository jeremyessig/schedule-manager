extends Control

onready var new_lesson_dialog := $NewLessonDialog
onready var new_subject_dialog := $NewSubjectDialog
onready var alert_dialog := $AlertDialog
onready var header : Panel = $App/Header
onready var export_dialog : FileDialog = $ExportDialog
onready var import_dialog : FileDialog = $ImportDialog
onready var export_csv_file_dialog : FileDialog = $ExportDialogCSV
onready var exporting_csv_dialog: Control = $ExportingCSVDialog
onready var about_dialog : WindowDialog = $AboutDialog


func _ready() -> void:
	Global.new_subject_button.connect("pressed", self, "_show_new_subject_dialog")
	header.connect("export_json_pressed", self, "_open_export_dialog")
	header.connect("import_json_pressed", self, "_open_import_dialog")
	header.connect("export_csv_pressed", self, "_open_export_csv_dialog")
	header.connect("about_pressed", self, "_open_about_dialog")
	
	




#________Methode d'affichage des dialogs_____________
#func _show_new_lesson_dialog() ->void:
#	new_lesson_dialog.show()

func _show_new_subject_dialog() ->void:
	new_subject_dialog.show()
	

func _open_export_dialog() -> void:
	export_dialog.popup_centered()

func _open_import_dialog() -> void:
	import_dialog.popup_centered()
	
func _open_export_csv_dialog() ->void:
	exporting_csv_dialog.show()

func _open_about_dialog() ->void:
	about_dialog.popup_centered()

func _on_FileDialog_file_selected(path):
	SaveSystem.export_to_JSON(path)


func _on_ImportDialog_file_selected(path):
	SaveSystem.import_from_JSON(path)


## Lance l'exportation en CSV
func _on_ExportDialogCSV_file_selected(path):
	SaveSystem.export_to_csv(path)

##Affiche le gestionnaire de fichier pour exporter en csv
func _on_ExportingCSVDialog_open_exporting_csv_file_dialog():
	export_csv_file_dialog.show()

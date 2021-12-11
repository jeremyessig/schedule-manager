extends Control

var screenshot = preload("res://tscn/prefabs/ScreenShot.tscn")


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
onready var route_dialog :Control = $RouteDialog
onready var preferences_dialog : Control = $PreferencesDialog
onready var tutorial_dialog : Control = $TutorialDialog
onready var export_as_png_dialog : FileDialog = $ExportAsPNGDialog

#onready var viewport_container : ViewportContainer = $ViewportContainer
#onready var viewport : Viewport = $ViewportContainer/Viewport
#onready var background : ColorRect = $ViewportContainer/Viewport/BackgroundColorRect

onready var autosave : Timer = $AutoSave


func _ready() -> void:
	OS.set_window_size(Preferences.start_window_size)
	_centering_screen(Preferences.start_window_size)
	Global.new_subject_button.connect("pressed", self, "_show_new_subject_dialog")
	Global.new_lesson_button.connect("pressed", self, "_show_new_lesson_dialog")
	header.connect("export_json_pressed", self, "_open_export_dialog")
	header.connect("import_json_pressed", self, "_open_import_dialog")
	header.connect("export_csv_pressed", self, "_open_export_csv_dialog")
	header.connect("about_pressed", self, "_open_about_dialog")
	Signals.connect("save_as_pressed", self, "_open_save_as_dialog")
	header.connect("open_save_pressed", self, "_open_open_save_dialog")
#	header.connect("route_pressed", self, "_on_open_route_dialog")
	Signals.connect("dialog_route_shown", self, "_on_open_route_dialog")
	header.connect("preferences_pressed", self, "_on_open_preferences_dialog")
	header.connect("export_png_pressed", self, "_open_export_as_PNG_dialog")
	print(get_tree().get_nodes_in_group("CM_lesson_cards"))
	if Preferences.tutorial_popup:
		tutorial_dialog.show()
	


func _centering_screen(screen_size:Vector2) ->void:
	var computer_screen : Vector2 = OS.get_screen_size()
	var centering_screen := Vector2(computer_screen.x, computer_screen.y)
	centering_screen = Vector2((centering_screen.x - screen_size.x)/2, (centering_screen.y - screen_size.y)/2)
	OS.set_window_position(centering_screen)	


func _unhandled_input(event):
	if event.is_action_pressed("save"):
		SaveSystem.save_to_res()
		return
	if event.is_action_pressed("last_file_opened"):
		if Preferences.last_res_file_loaded == "":
			return
		SaveSystem.load_from_res(Preferences.last_res_file_loaded)
		return
	if event.is_action_pressed("open_saves"):
		open_save_dialog.popup_centered()
		return
	if event.is_action_pressed("show_route_dialog"):
		Signals.emit_signal("dialog_route_shown")
		return


func _on_AutoSave_timeout():
	if not Preferences.autosave:
		return
	if autosave.wait_time != Preferences.autosave_wait_time:
		autosave.wait_time = Preferences.autosave_wait_time
	SaveSystem.save_to_res()
	

func export_as_png(path):
	var calendar_size = Vector2(2339,1372)
	var A4_page_size = Vector2(2339, 1654) #200 dpi
	var tmp_position :Vector2 = Global.right_panel.rect_position
	var tmp_size : Vector2 = Global.right_panel.rect_size
	var instance = screenshot.instance()
	self.add_child(instance)
	var viewport_container = self.get_child(self.get_child_count()-1)
	var viewport = viewport_container.get_child(0)
	var background = viewport.get_child(0)
	Global.reparent_node(Global.hsplit_container, Global.right_panel, viewport)
	Global.right_panel.rect_position = Vector2(0, A4_page_size.y - calendar_size.y - 60)
	Global.right_panel.rect_size = calendar_size
	viewport_container.rect_size = A4_page_size
	viewport.size = A4_page_size
	background.rect_size = A4_page_size
	Signals.emit_signal("png_export_started")
	yield(VisualServer, "frame_post_draw")
	var img = viewport.get_texture().get_data()
	Signals.emit_signal("png_export_ended")
	viewport_container.queue_free()
	Global.right_panel.rect_position = tmp_position
	Global.right_panel.rect_size = tmp_size
	Global.reparent_node(viewport, Global.right_panel, Global.hsplit_container)
	img.flip_y()
	img.save_png(path)


#________Methode d'affichage des dialogs_____________
func _show_new_lesson_dialog() ->void:
	Signals.emit_signal("dialog_new_lesson_shown")
#	new_lesson_dialog.check_subject_lesson_database()
#	new_lesson_dialog.reset_default_GUI()
#	new_lesson_dialog.set_lesson_duration()
#	new_lesson_dialog.show()

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
	
func _open_export_as_PNG_dialog() ->void:
	export_as_png_dialog.popup_centered()
	
func _open_save_as_dialog() ->void:
	save_as_dialog.popup_centered()

func _open_open_save_dialog() ->void:
	open_save_dialog.popup_centered()

func _on_open_route_dialog() ->void:
	route_dialog.show()

func _on_open_preferences_dialog() ->void:
	preferences_dialog.show()

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




func _on_ExportAsPNG_file_selected(path):
	export_as_png(path)

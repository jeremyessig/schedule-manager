extends Node
var key_reference : Array #Clefs de reference pour tester la compatibilite (init dans LeftPanel)
var version : float

#const SAVE_VAR := "user://sav1.sav"

func _ready():
	version = ProjectSettings.get_setting("application/config/version")

#######################################################################
############################ SAUVEGARDE
######################################################################

func save_var(path:String) -> void:
	var file := File.new()
	file.open(path, File.WRITE)

	for node in get_tree().get_nodes_in_group("lesson_cards"):
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("export_to_json"):
			print("persistent node '%s' is missing a save_var() function, skipped" % node.name)
			continue
		node.save_to_var(file)

	file.close()
	print_debug("Saved")


func load_var(path) -> void:
	# Instances a new `File` in read mode and attempt to load the file, if it is
	# open-able and readable.
	print(path)
	var i = 0
	while i < 20:
		Global.left_panel.create_lesson_card({})
		i += 1
	
	var file := File.new()
	var error := file.open(path, File.READ)
#
#	if not error == OK:
#		print("Could not load file at %s" % path)
#		return
#
#	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
#		lesson_card.delete()
#	# Send the loaded file to each child in the same order they were saved to
#	# have them load their data.
##	print(file.get_position())
##	print(file.get_len())
#	var i = 0
	for node in get_tree().get_nodes_in_group("lesson_cards"):
		node.load_from_var(file)
#
##	for child in get_children():
##		child.load_from_var(file)
#
#	# Clean up
	file.close()



#######################################################################
################### TRAITEMENT DES FICHIERS JSON ######################
#######################################################################

##________________Retro-compatibilite des fichiers_______________________

## Verifie si les donnees de la sauvegarde son compatibles
func is_compatible(data:Dictionary) ->bool:
	return data.has_all(key_reference)


func update_compatibility(node_data:Dictionary) -> void:
	node_data["version"] = version
			


##_____________ ___Import et export en JSON ______________________________
func export_to_JSON(path:String) -> void:
	var export_to_json = File.new()
	if not path.get_extension() == "json":
		Signals.emit_signal("error_emitted", "SavingWrongFormat", null)
		return
	export_to_json.open(path, File.WRITE)
	var export_nodes = get_tree().get_nodes_in_group("lesson_cards")
	
	
	for node in export_nodes:
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("export_to_json"):
			print("persistent node '%s' is missing a export_to_json() function, skipped" % node.name)
			continue
		var node_data = node.call("export_to_json")
		export_to_json.store_line(to_json(node_data))
	export_to_json.close()
	print_debug("Datas exported to JSON")
		


func import_from_JSON(path:String) ->void:
	var data_file = File.new()
	if not data_file.file_exists(path):
		print("File doesn't exist !")
		return
		
	if not path.get_extension() == "json":
		Signals.emit_signal("error_emitted", "LoadingWrongFormat", null)
		return
	
	## Detruit les cours presents dans le programme
	var save_nodes = get_tree().get_nodes_in_group("lesson_cards")
	for i in save_nodes:
		i.delete()
	Global.subjects_database.clear()
	Global.lessons_database.clear()
	
	data_file.open(path, File.READ)
	while data_file.get_position() < data_file.get_len():
		var node_data = parse_json(data_file.get_line())
		if not node_data is Dictionary or !node_data.has("version"):
			Signals.emit_signal("error_emitted", "LoadingWrongFormat" ,null)
			data_file.close()
			return
		if node_data["version"] != version:
			if node_data["version"] > version:
				Signals.emit_signal("error_emitted", "OldVersion", null)
				data_file.close()
				return
			if not is_compatible(node_data):
				Signals.emit_signal("error_emitted", "LoadingOldSave", null)
				data_file.close()
				return
		Global.left_panel.create_lesson_card(node_data)
		if not Global.subjects_database.has(node_data["subject"]):
			Global.subjects_database.append(node_data["subject"])
		Signals.emit_signal("subject_added")
		Global.update_option_button(Global.new_subject_dialog.remove_subject_option_button, Global.subjects_database)
		if not Global.lessons_database.has(node_data["lesson"]):
			Global.lessons_database[node_data["lesson"]] = [node_data["lesson"], node_data["subject"]]
		Signals.emit_signal("lesson_added")
		Global.update_option_button(Global.new_subject_dialog.remove_lesson_option_button, Global.lessons_database)
		Global.update_option_button(Global.new_subject_dialog.define_lesson_subject_option_button, Global.subjects_database)
		
	data_file.close()
	



func export_to_csv(path:String) ->void:
	var export_to_csv = File.new()
	if not path.get_extension() == "csv":
		Signals.emit_signal("error_emitted", "SavingWrongFormat", null)
		return
	export_to_csv.open(path, File.WRITE)
	var export_nodes = get_tree().get_nodes_in_group("lesson_cards")
	
	var title : PoolStringArray = ["Subject", "Start Date", "Start Time", "End Date", "End Time", "All Day Event", "Description", "Location", "Private"]
	export_to_csv.store_csv_line(title, ",")
	for node in export_nodes:
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("export_to_csv"):
			print("persistent node '%s' is missing a export_to_csv() function, skipped" % node.name)
			continue
		if node.is_displayed:
			var node_data = node.call("export_to_csv")
			export_to_csv.store_csv_line(node_data, ",")
	export_to_csv.close()
	print_debug("Datas exported to csv")









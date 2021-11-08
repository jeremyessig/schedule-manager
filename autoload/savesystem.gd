extends Node


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
		i.queue_free()
	
	data_file.open(path, File.READ)
	while data_file.get_position() < data_file.get_len():
		var node_data = parse_json(data_file.get_line())
		if not node_data is Dictionary or !node_data.has("version") or node_data["version"] != ProjectSettings.get_setting("application/config/version"):
			data_file.close()
			if not node_data is Dictionary or !node_data.has("version"):
				Signals.emit_signal("error_emitted", "LoadingWrongFormat" ,null)
			elif node_data["version"] < ProjectSettings.get_setting("application/config/version"):
				Signals.emit_signal("error_emitted", "LoadingOldSave", null)
			elif node_data["version"] > ProjectSettings.get_setting("application/config/version"):
				Signals.emit_signal("error_emitted", "OldVersion", null)
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









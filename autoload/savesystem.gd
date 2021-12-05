extends Node
var key_reference : Array #Clefs de reference pour tester la compatibilite (init dans LeftPanel)
var version : float

const SaveAsResource = preload("res://classes/save_as_resource.gd")
var path_to_save : String
var last_opened_path : String

func _ready():
	version = ProjectSettings.get_setting("application/config/version")

#######################################################################
############################ SAUVEGARDE
######################################################################

func save_to_res(path:String = "") -> void:
	if path == "" and path_to_save == "":
		Signals.emit_signal("save_as_pressed")
		return 
	if path == "":
		path = path_to_save
	var save := SaveAsResource.new()
	save.version = version
	save.route = Global.get_routes_database()
	save.subject = Global.get_subjects_database()
	save.lesson = Global.get_lessons_database()
	save.location = Global.get_locations_database()
	for node in get_tree().get_nodes_in_group("occupied_cells"):
		if !node.has_method("save_to_res"):
			print("persistent node '%s' is missing a save_var() function, skipped" % node.name)
			continue
		save.cell.append(node.save_to_res())
	for node in get_tree().get_nodes_in_group("lesson_cards"):
		if !node.has_method("save_to_res"):
			print("persistent node '%s' is missing a save_var() function, skipped" % node.name)
			continue
		save.data.append(node.save_to_res())
	ResourceSaver.save(path, save)
	path_to_save = path


func load_from_res(path) -> void:
	if !path.ends_with(".res"):
		Signals.emit_signal("error_emitted", "LoadingWrongFormat" ,null)
		return
	var file = File.new()
	for lesson_card in get_tree().get_nodes_in_group("lesson_cards"):
		lesson_card.delete()
	Global.reset_databases()
	if not file.file_exists(path):
		print("ERROR: file doesn't exist !")
		return
	var save : Resource = load(path)
	Global.set_routes_database(save.route)
	Global.set_lessons_database(save.lesson)
	Global.set_subjects_database(save.subject)
	Global.set_locations_database(save.location)
	for cell in get_tree().get_nodes_in_group("cell_buttons"):
		cell.reset()
		if save.cell.has(var2str(Vector2(cell.position))):
			cell.set_cell()
	for node_data in save.data:
		if not is_compatible(node_data):
			return
		node_data["version"] = version
		Global.left_panel.create_lesson_card(node_data)
	last_opened_path = path
	path_to_save = path
	
	
		



#######################################################################
################### TRAITEMENT DES FICHIERS JSON ######################
#######################################################################

##________________Retro-compatibilite des fichiers_______________________

## Verifie si les donnees de la sauvegarde son compatibles
func is_same_keys(data:Dictionary) ->bool:
	return data.has_all(key_reference)


func update_compatibility(node_data:Dictionary) -> void:
	node_data["version"] = version
			

func is_compatible(node_data) -> bool:
	if not node_data is Dictionary or !node_data.has("version"):
		Signals.emit_signal("error_emitted", "LoadingWrongFormat" ,null)
		return false
	if node_data["version"] != version:
		if node_data["version"] > version:
			Signals.emit_signal("error_emitted", "OldVersion", null)
			return false
		if not is_same_keys(node_data):
			Signals.emit_signal("error_emitted", "LoadingOldSave", null)
			return false
	return true


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
	if !path.ends_with(".json"):
		Signals.emit_signal("error_emitted", "LoadingWrongFormat" ,null)
		return		
	var data_file = File.new()
	if not data_file.file_exists(path):
		print("File doesn't exist !")
		return
		
	if not path.get_extension() == "json":
		Signals.emit_signal("error_emitted", "LoadingWrongFormat", null)
		return
	
	var save_nodes = get_tree().get_nodes_in_group("lesson_cards")
	var id_table: Array ## Liste les cours present dans le programme via leur id
	for i in save_nodes: ## Cree un tableau avec toutes les id
		id_table.append(i["id"])
	
	data_file.open(path, File.READ)
	while data_file.get_position() < data_file.get_len():
		var node_data = parse_json(data_file.get_line())
		if not is_compatible(node_data):
			data_file.close()
			return
		if id_table.find(node_data["id"]) != -1: ## Si l'id du cours est present dans le tableau, il n'est pas charge !
			continue  ## Cela permet d'eviter les doublons
		Global.left_panel.create_lesson_card(node_data)
		if not Global.subjects_database.has(node_data["subject"]):
			Global.add_to_subjects_database(node_data["subject"])
		if not Global.locations_database.has(node_data["location"]):
			Global.add_to_locations_database(node_data["location"])
		if not Global.lessons_database.has(node_data["lesson"]):
			Global.add_to_lessons_database(node_data["lesson"], [node_data["lesson"], node_data["subject"]])
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









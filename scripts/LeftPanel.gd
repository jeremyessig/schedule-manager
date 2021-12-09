extends Panel

var lesson_card := preload("res://tscn/LessonCard.tscn")

var one_columns_white := preload("res://assets/icons/1_columns_white.png")
var one_columns_focus := preload("res://assets/icons/1_columns_focus.png")
var two_columns_white := preload("res://assets/icons/2_columns_white.png")
var two_columns_focus := preload("res://assets/icons/2_columns_focus.png")
var tree_columns_white := preload("res://assets/icons/3_columns_white.png")
var tree_columns_focus := preload("res://assets/icons/3_columns_focus.png")
var four_columns_white := preload("res://assets/icons/4_columns_white.png")
var four_columns_focus := preload("res://assets/icons/4_columns_focus.png")


onready var td_container := $VBoxContainer/HBoxContainer2/VBoxContainer/ScrollContainer/ClassContainer/TDContainer
onready var cm_container := $VBoxContainer/HBoxContainer2/VBoxContainer/ScrollContainer/ClassContainer/CMContainer
onready var buttons_grid_container := $VBoxContainer/NewClassContainer/ButtonsGridContainer
onready var search_line_edit: LineEdit = $VBoxContainer/SearchContainer/SearchLineEdit
onready var display_columns_container : HBoxContainer = $VBoxContainer/DisplayColumnsContainer
onready var one_columns_btn : TextureButton = $VBoxContainer/DisplayColumnsContainer/OneColumnsBtn
onready var two_columns_btn : TextureButton = $VBoxContainer/DisplayColumnsContainer/TwoColumnsBtn
onready var tree_columns_btn : TextureButton = $VBoxContainer/DisplayColumnsContainer/TreeColumnsBtn
onready var four_columns_btn : TextureButton = $VBoxContainer/DisplayColumnsContainer/FourColumnsBtn
onready var temp := $Temp
onready var sort_btn := $SortBtn


##______________Fonctions d'initialisation________________________
func _ready() -> void:
	Signals.connect("lesson_created",self,"create_lesson_card") ## From NewLessonDialog by Signals
	Signals.connect("lesson_edited", self, "edit_lesson_card") ## From EditLessonDialog by Signals
	Signals.connect("lesson_cell_opened", self, "lesson_cell_opened")
	Signals.connect("preference_number_of_columns_setted", self, "_set_number_of_columns")
	_init_key_reference()
	_set_number_of_columns()


## Cree une carte temporaire pour recuperer les clefs des data
## Ces clefs sont utilisees comme modele de reference pour valider la retro-compatibilite des sauvegardes
func _init_key_reference():	
	create_lesson_card({})
	var child = temp.get_child(0)
	var dic = child.get_data()
	SaveSystem.key_reference = dic.keys()
	child.queue_free()
	
	
func _physics_process(_delta: float) -> void:
	_responsive_TDCM_container()


##___________________Creation des cartes de cours___________________________________
func does_lesson_exist(card_id: String, type:String):
	var container : GridContainer
	if type == "Travaux Dirigés":
		container = td_container
	if type == "Cours Magistral":
		container = cm_container
	for child in container.get_children():
		if child.id == card_id:
			return true
	return false


func edit_lesson_card(datas:Dictionary, old_id:String) ->void:
	var card : Button = find_lesson_card(old_id)
	var old_type : String = card.type
	card.set_data(datas)
	if card.type != old_type:
		var parent = card.get_parent()
		add_lesson_card_to_container(card, parent)
	card.emit_signal("lesson_cell_updated", datas, "")
	

func lesson_cell_opened(id) -> void:
	var node : Button = find_lesson_card(id)
	var node_path :NodePath = node.get_path()
	Signals.emit_signal("lesson_card_pressed", node_path)
	

func create_lesson_card(data:Dictionary) ->void:
	var instance = lesson_card.instance()
	temp.add_child(instance)
	var child = temp.get_child(0)
	if !data.empty():
		child.load_data(data)
		add_lesson_card_to_container(child, temp)


func get_all_lesson_cards() ->Array:
	var table:Array
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		table.append(card)	
	return table


func add_lesson_card_to_container(child:Node, source:Node) ->void:
	if child.type == "Cours Magistral":
		Global.reparent_node(source, child, cm_container)
	if child.type == "Travaux Dirigés":
		Global.reparent_node(source, child, td_container)


func find_lesson_card(id:String) ->Node:
	for card in cm_container.get_children():
		if card.id == id:
			return card
	for card in td_container.get_children():
		if card.id == id:
			return card
	print_debug("Error: No lesson card found")
	return null


func clear_CM_and_TD_containers()->void:
	for card in cm_container.get_children():
		Global.reparent_node(cm_container, card, temp)
	for card in td_container.get_children():
		Global.reparent_node(td_container, card, temp)	
		
			
		
##_____________________ Triage des cours_______________________________
func sort_cards(invert:bool):
	var table = sort_lessons_by_letters()
	if invert == true:
		table.invert()
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		if card.type == "Cours Magistral":
			Global.reparent_node(cm_container, card, temp)
		if card.type == "Travaux Dirigés":
			Global.reparent_node(td_container, card, temp)
	for matrix in table:
		add_lesson_card_to_container(matrix[1], temp)
		matrix[1].index = matrix[1].get_index()
	sort_btn.flip_v = invert		


func sort_lessons_by_letters() ->Array:
	var table: Array
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		var matrix = [card.id, card]
		table.append(matrix)
	table.sort_custom(Sort, "sort_ascending")
	return table


func sort_lessons_by_subjects(invert:bool = false) ->void:
	var subjects_list:Array = Global.get_subjects_database()
	var table: Array
	table = get_all_lesson_cards()
	table = Sort.by_subjects(table, subjects_list, invert)
	dispatch_sorted_cards_to_CM_and_TD_containers(table)


func sort_lessons_by_rating(invert:bool = false) ->void:
	var table: Array
	table = get_all_lesson_cards()
	table = Sort.by_rating(table, 5)
	if !invert:
		table.invert()
	dispatch_sorted_cards_to_CM_and_TD_containers(table)


func sort_lessons_by_days(invert:bool = false) ->void:
	var table: Array
	var weekday: Array = Global.get_weekday()
	table = get_all_lesson_cards()
	table = Sort.by_days(table, weekday, invert)
	dispatch_sorted_cards_to_CM_and_TD_containers(table)	


func dispatch_sorted_cards_to_CM_and_TD_containers(table:Array) ->void:
	for card in table:
		if card.type == "Cours Magistral":
			Global.reparent_node(cm_container, card, cm_container)
		if card.type == "Travaux Dirigés":
			Global.reparent_node(td_container, card, td_container)	

#func set_lesson_card(id:String) ->void:
#	var card = find_lesson_card(id)
#	card.is_displayed = false

	

##________________ Methode de recherche_____________________

func _get_subsequence_of_lesson_cards(text:String) -> Array:
	var table : Array
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		if text.is_subsequence_ofi(card.lesson):
			table.append(card)
	return table ## contient les cartes avec les bons noms


func _refresh_searched_card(new_text) ->void:
	clear_CM_and_TD_containers()
	var lesson_cards_found : Array = _get_subsequence_of_lesson_cards(new_text)
	for card in lesson_cards_found:
		add_lesson_card_to_container(card, temp)


func clear_searched() ->void:	
	search_line_edit.clear()
	clear_CM_and_TD_containers()
	for card in get_tree().get_nodes_in_group("lesson_cards"):
		add_lesson_card_to_container(card, temp)


##___________________Affichage responsive_______________________________
## Ecart de 340 px
func _responsive_TDCM_container():
	buttons_grid_container.columns = 2
	if self.rect_size.x >= 1700:
		td_container.columns = 5
		cm_container.columns = 5
		return
	if self.rect_size.x >= 1360:
		td_container.columns = 4
		cm_container.columns = 4
		return
	if self.rect_size.x >= 1020:
		td_container.columns = 3
		cm_container.columns = 3
		return
	if self.rect_size.x >= 680:
		td_container.columns = 2
		cm_container.columns = 2
		buttons_grid_container.columns = 2
		return
	td_container.columns = 1
	cm_container.columns = 1
	buttons_grid_container.columns = 1


## Non fonctionnel...
func _set_number_of_columns(value = Preferences.number_of_columns) ->void:
	one_columns_btn.set("texture_normal", one_columns_white)
	two_columns_btn.set("texture_normal", two_columns_white)
	tree_columns_btn.set("texture_normal", tree_columns_white)
	four_columns_btn.set("texture_normal", four_columns_white)
		
	match value:
		1:
			self.rect_min_size.x = 360
			self.rect_size.x = 360
			Global.right_panel.rect_size.x += 360
			one_columns_btn.set("texture_normal", one_columns_focus)
			td_container.columns = 1
			cm_container.columns = 1
		2:
			self.rect_min_size.x = 680
#			self.rect_size.x = 680
			two_columns_btn.set("texture_normal", two_columns_focus)
			td_container.columns = 2
			cm_container.columns = 2
		3:
			self.rect_min_size.x = 1020
#			self.rect_size.x = 1020
			tree_columns_btn.set("texture_normal", tree_columns_focus)
			td_container.columns = 3
			cm_container.columns = 3
			
		4:
			self.rect_min_size.x = 1360
			self.rect_size.x = 1360
			four_columns_btn.set("texture_normal", four_columns_focus)
			td_container.columns = 4
			cm_container.columns = 4


##__________________Methode connectees_______________________		
	
func _on_SortBtn_toggled(button_pressed):
	sort_cards(button_pressed)


func _on_SearchLineEdit_text_changed(new_text):
	_refresh_searched_card(new_text)


#func _on_SearchLineEdit_focus_exited():
#	call_deferred("clear_searched") ## Sinon pas possible de cliquer sur la carte




func _on_ClearBSearchBtn_pressed():
	call_deferred("clear_searched")



func _on_OneColumnsBtn_pressed():
	Preferences.number_of_columns = 1


func _on_TwoColumnsBtn_pressed():
	Preferences.number_of_columns = 2


func _on_TreeColumnsBtn_pressed():
	Preferences.number_of_columns = 3


func _on_FourColumnsBtn_pressed():
	Preferences.number_of_columns = 4

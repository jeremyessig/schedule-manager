extends Panel

var lesson_card := preload("res://tscn/LessonCard.tscn")

onready var td_container := $VBoxContainer/HBoxContainer2/VBoxContainer/ScrollContainer/ClassContainer/TDContainer
onready var cm_container := $VBoxContainer/HBoxContainer2/VBoxContainer/ScrollContainer/ClassContainer/CMContainer
onready var buttons_grid_container := $VBoxContainer/NewClassContainer/ButtonsGridContainer
onready var temp := $Temp


##______________Fonctions d'initialisation________________________
func _ready() -> void:
	Signals.connect("lesson_created",self,"create_lesson_card") ## From NewLessonDialog by Signals
	Signals.connect("lesson_edited", self, "edit_lesson_card") ## From EditLessonDialog by Signals
	Signals.connect("lesson_card_deleted", self, "delete_lesson_card") ## From EditLessonDialog by Signals
	Signals.connect("lesson_deleted_from_calendar", self, "set_lesson_card")
	Signals.connect("lesson_cell_opened", self, "lesson_cell_opened")
	
	
func _physics_process(_delta: float) -> void:
	_responsive_TDCM_container()


##___________________Creation des cartes de cours___________________________________
func does_lesson_exist(card_id: String, type:String):
	var container :Node
	if type == "Travaux Dirigés":
		container = td_container
	if type == "Cours Magistral":
		container = cm_container
	for child in container.get_children():
		if child.id == card_id:
			return true
	return false



func edit_lesson_card(datas:Dictionary, old_id:String) ->void:
	var card = find_lesson_card(old_id)
	var old_type = card.type
	card.assigning_dictionary_values(datas)
	card.update_infos()
	if card.type != old_type:
		var parent = card.get_parent()
		add_lesson_card_to_container(card, parent)
	card.emit_signal("updating_lesson_cell", datas)
	

func lesson_cell_opened(id) -> void:
	var node = find_lesson_card(id)
	var node_path = node.get_path()
	Signals.emit_signal("lesson_card_pressed", node_path)
	

func create_lesson_card(lesson:Dictionary) ->void:
	var instance = lesson_card.instance()
	temp.add_child(instance)
	var child = temp.get_child(0)
	child.assigning_dictionary_values(lesson)
	child.update_infos()
	add_lesson_card_to_container(child, temp)



func add_lesson_card_to_container(child:Node, source:Node) ->void:
	if child.type == "Cours Magistral":
		Global.reparent_node(source, child, cm_container)
	if child.type == "Travaux Dirigés":
		Global.reparent_node(source, child, td_container)


func set_lesson_card(id:String) ->void:
	var card = find_lesson_card(id)
	card.is_displayed = false


func find_lesson_card(id:String) ->Node:
	for card in cm_container.get_children():
		if card.id == id:
			return card
	for card in td_container.get_children():
		if card.id == id:
			return card
	print_debug("Error: No lesson card found")
	return null


func delete_lesson_card(id:String) ->void:
	find_lesson_card(id).queue_free()
	

##___________________Affichage responsive_______________________________
## Ecart de 340 px
func _responsive_TDCM_container():
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

		
	

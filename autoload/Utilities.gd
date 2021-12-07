extends Node


func _ready():
	pass

## Remet du programme a zero mais les parametres sont conserves
func reset_program() ->void:
	Signals.emit_signal("program_reseted")
	yield(get_tree(),"idle_frame")


## Remet l'integralite du programme a zero (carte, emploi du temps, parametre, etc.)
func reset_program_to_default() ->void:
	Signals.emit_signal("program_reseted")
	yield(get_tree(),"idle_frame")

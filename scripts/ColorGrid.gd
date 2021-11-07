extends GridContainer

signal color_picked(color) ## -> NewLessonDialog



func _on_DodgerBlueButton_pressed() -> void:
	emit_signal("color_picked","#1e90ff")



func _on_DarkBlueButton_pressed() -> void:
	emit_signal("color_picked","#282897")



func _on_PurpleButton_pressed() -> void:
	emit_signal("color_picked","#632e99")



func _on_MagentaButton_pressed() -> void:
	emit_signal("color_picked","#a83374")



func _on_RedButton_pressed() -> void:
	emit_signal("color_picked","#971818")



func _on_OrangeButton_pressed() -> void:
	emit_signal("color_picked","#eb760c")



func _on_YellowButton_pressed() -> void:
	emit_signal("color_picked","#facf39")



func _on_LightGreenButton_pressed() -> void:
	emit_signal("color_picked","#85c533")



func _on_ForestGreenButton_pressed() -> void:
	emit_signal("color_picked","#228b22")



func _on_BlackButton_pressed() -> void:
	emit_signal("color_picked","#2b2b2b")


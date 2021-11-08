extends WindowDialog

onready var version_label = $CenterContainerBody/VBoxContainer/VersionLabel

func _ready():
	var version = ProjectSettings.get_setting("application/config/version") 
	version_label.text = "Version du logiciel n°%s" %version

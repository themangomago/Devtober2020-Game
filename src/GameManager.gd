extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect_signal("CameraSwitch", self, "switchCamera")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func switchCamera(type):
	
	if type == Types.CameraTypes.InGame:
		$Computer.hide()
		$GameWorld.show()
		$GameWorld.setCamera()
	else:
		$Computer.show()
		$GameWorld.hide()
		$Computer.setCamera()

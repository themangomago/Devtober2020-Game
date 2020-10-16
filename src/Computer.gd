extends Control

func setCamera():
	$Camera2D.make_current()

func _on_Ide_button_up():
	$WindowManager.startApplication(0)


func _on_TextureButton_button_up():
	$WindowManager.startApplication(0)


func _on_ShutDown_button_up():
	Events.emit_signal("CameraSwitch", Types.CameraTypes.InGame)

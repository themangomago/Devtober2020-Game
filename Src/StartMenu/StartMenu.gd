extends NinePatchRect


func toggle():
	if visible:
		hide()
	else:
		show()

func _process(delta):
	if visible:
		if Input.is_action_just_pressed("ui_accept"):
			toggle()

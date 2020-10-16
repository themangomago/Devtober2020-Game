extends Sprite

func _physics_process(delta):
	self.global_position = get_viewport().get_mouse_position()

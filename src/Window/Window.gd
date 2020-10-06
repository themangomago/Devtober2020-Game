extends NinePatchRect

signal window_focus
signal window_close
signal window_minimize
signal window_open

export var appId = 0

var dragPosition = null

var wm = null

func _ready():
	# Set App Title
	$WindowControl/Title.set_text(Global.Apps[appId].name)
	
	# Set Icon Texture
	var iconTexture = load(Global.Apps[appId].icon)
	if iconTexture == null:
		print_debug("Error: Icon not found")
	else:
		$WindowControl/Icon.set_texture(iconTexture)
	
	wm = get_parent()
	wm.registerWindow(self, visible)


func _on_Close_button_up():
	focusWindow()
	closeWindow()


func _on_Minimize_button_up():
	minimizeWindow()


func _on_Window_gui_input(event):
	if event is InputEventMouseButton:
		focusWindow()


func _on_WindowControl_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			dragPosition = get_global_mouse_position() - rect_global_position
			focusWindow()
		else:
			dragPosition = null
	if event is InputEventMouseMotion:
		if dragPosition:
			rect_global_position = get_global_mouse_position() - dragPosition

func focusWindow():
	emit_signal("window_focus", self)

func closeWindow():
	hide()
	emit_signal("window_close", self)

func minimizeWindow():
	hide()
	emit_signal("window_minimize", self)
	
func openWindow():
	show()
	focusWindow()

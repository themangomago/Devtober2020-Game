extends Control

#{state = Types.WindowStates.Closed, node = window}
var windowStack = []

func registerWindow(window, open = false):
	var thisState = Types.WindowStates.Closed
	if open == true:
		thisState = Types.WindowStates.Open
		
	windowStack.append({state = thisState, node = window})
	window.connect("window_focus", self, "_window_focus")
	window.connect("window_close", self, "_window_close")
	window.connect("window_minimize", self, "_window_minimize")

func startApplication(id):
	for app in windowStack:
		if id == app.node.appId:
			match app.state:
				Types.WindowStates.Closed:
					if app.node.has_method("init"):
						app.node.init()
					app.node.openWindow()
				Types.WindowStates.Minimized:
					app.node.openWindow()
				_:
					print("Already opened")

func _window_focus(window):
	move_child(window, get_child_count() - 1)


func _window_close(node):
	changeWindowState(node.appId, Types.WindowStates.Closed)


func _window_minimize(node):
	changeWindowState(node.appId, Types.WindowStates.Minimized)


func changeWindowState(id, toState):
	for app in windowStack:
		if id == app.node.appId:
			app.state = toState

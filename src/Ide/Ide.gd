extends "res://src/Window/Window.gd"

var compiledSource = []

func _ready():
	$Cpu.setNodeMemoryView($MemoryView)




func _on_Run_button_up():
	var line = $Cpu.next()


func _on_Compile_button_up():
	var result = Compiler.compile($ConsoleInput.get_text())

	if result.status == OK:
		print(result)
		#compiledSource = result.tokenArray
		$ConsoleLog.add("Source compiled successfully..")
		#$ConsoleInputError.hide()
	else:
		compiledSource = []
		for index in range(result.tokenArray.size()):
			var error = Compiler.containsErrorReturnString(index, result.tokenArray[index])
			if error[0] == true:
				$ConsoleLog.error(error[1])
		#$ConsoleInputError.show()


func _on_LoadCode_button_up():
	if compiledSource.size() > 0:
		$ConsoleLog.add("Flashed code to CPU ...")
		$Cpu.loadCode(compiledSource)
	else:
		$ConsoleLog.error("No compiled source found")

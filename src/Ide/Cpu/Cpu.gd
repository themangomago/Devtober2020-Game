extends Control

var refMemoryView = null

enum ArithmeticTypes {Add, Sub, Mul}

var cpu = {
	acc = 0,
	reg = [0, 0, 0, 0, 0, 0, 0, 0],
	pin = [0, 0, 0, 0, 0, 0, 0, 0],
	state = 0,
	power = 0,
	ram = [0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	rom = [0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
}

var codeBase = []

var pointer = 0

func _ready():
	updateLabel()
	

func setNodeMemoryView(node):
	refMemoryView = node
	updateMemoryView() # Update

func updateMemoryView():
	if refMemoryView == null:
		print("refMemoryView not set")
		return
	refMemoryView.updateMemoryView(cpu)

func updateLabel():
	var regStr = ""
	var pinStr = ""
	
	for val in cpu.reg:
		regStr += str(val) + " "
	
	for val in cpu.pin:
		pinStr += str(val) + " "
	
	$Label.bbcode_text = \
		"acc: "+ str(cpu.acc) + "\n" + \
		"reg: " + regStr + "\n" +  \
		"pin: " + pinStr + "\n" +  \
		"state:" + str(cpu.state) + "\n" + \
		"pointer:" + str(pointer)


func reset():
	pointer = 0


func loadCode(code):
	codeBase = code
	reset()


func next():
	if pointer >= codeBase.size():
		pointer = 0
	
	var line = codeBase[pointer]

	# MOV, ADD, SUB, NOP
	match line.command:
		"MOV":
			instructionMOV(line.args[0], line.args[1])
		"ADD":
			instructionArithmetic(line.args[0], ArithmeticTypes.Add)
		"SUB":
			instructionArithmetic(line.args[0], ArithmeticTypes.Sub)
		"MUL":
			instructionArithmetic(line.args[0], ArithmeticTypes.Mul)
		"NOP":
			print("nop")
		_:
			Global.Console.error("Runtime error " + line.command + ": " + line.error)
	
	pointer += 1
	updateLabel()
	return pointer

func instructionArithmetic(value, operator):
	var actualValue = 0

	if Compiler.isAddress(value):
		actualValue = getValueFromAddress(value)
	else:
		# Number to acc
		actualValue = value
	
	match operator:
		ArithmeticTypes.Add:
			cpu.acc += actualValue
		ArithmeticTypes.Sub:
			cpu.acc -= actualValue
		ArithmeticTypes.Mul:
			cpu.acc *= actualValue
		_:
			print("Unsupported Arithmetic Type")


func instructionMOV(arg, target):
	var fromValue = 0

	if not Compiler.isAddress(target):
		Global.Console.error("Target is not a valid address")
		return

	var targetIndex = int(target.lstrip(1))

	# Parsing from arg
	if Compiler.isAddress(arg):
		fromValue = getValueFromAddress(arg)
	else:
		fromValue = arg

	print(fromValue)
	# Set to target
	setValueToAddress(target, fromValue)


func setValueToAddress(arg, value):
	var firstLetter = arg[0]
	
	match firstLetter:
		"a":
			cpu.acc = value
		"p":
			var index = int(arg.lstrip(1))
			cpu.pin[index] = value
		"r":
			var index = int(arg.lstrip(1))
			cpu.reg[index] = value
		"$":
			var addr = ("0x" + arg.trim_prefix("$")).hex_to_int()
			
			if addr >= Compiler.addresses.ram.start and addr < Compiler.addresses.ram.start + Compiler.addresses.ram.size:
				#Is Ram
				cpu.ram[addr - Compiler.addresses.ram.start] = value
			else:
				#Is Rom
				cpu.rom[addr - Compiler.addresses.rom.start] = value
		_:
			print("setValueToAddress error")
	updateMemoryView()

func getValueFromAddress(arg):
	var firstLetter = arg[0]
	var retVal = 0
	
	match firstLetter:
		"a":
			#ACC
			retVal = cpu.acc
		"p":
			var index = int(arg.lstrip(1))
			retVal = cpu.pin[index]
		"r":
			var index = int(arg.lstrip(1))
			retVal = cpu.reg[index]
		"$":
			var addr = ("0x" + arg.trim_prefix("$")).hex_to_int()
			
			if addr >= Compiler.addresses.ram.start and addr < Compiler.addresses.ram.start + Compiler.addresses.ram.size:
				#Is Ram
				retVal = cpu.ram[addr - Compiler.addresses.ram.start]
			else:
				#Is Rom
				retVal = cpu.rom[addr - Compiler.addresses.rom.start]
		_:
			print("getValueFromAddress error")
	return retVal

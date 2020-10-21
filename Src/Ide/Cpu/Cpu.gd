extends Control

#signal CpuReset
#signal CpuDebugLine

var refMemoryView = null

enum ArithmeticTypes {Add, Sub, Mul, Div, Inc, Dec, And, Or, Xor}
enum BitOpTypes {Set, Get, Clear, ShiftLeft, ShiftRight, RotateLeft, RotateRight}
enum CompareType {Equal, NotEqual, Greater, Lesser, GreaterThan, LesserThan}


enum CpuState {Halted = 0, Run}


var cpu = {
	acc = 0,
	ctrl = 0,
	reg = [0, 0, 0, 0, 0, 0, 0, 0],
	pin = [0, 0, 0, 0, 0, 0, 0, 0],
	state = CpuState.Halted,
	power = 0,
	ram = [0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	rom = [0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
}

var codeBase = []

var pointer = 0
var returnAddr = []
var step = 0

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
	
#	if codeBase.size() > 0:
#		Events.emit_signal("IdeCpuDebugLine", codeBase.tokenArray[pointer].line)
#		print("Executed Line: " + str(codeBase.tokenArray[pointer].line) + " command: " +  codeBase.tokenArray[pointer].command)

func reset():
	pointer = 0
	emit_signal("CpuReset")

func loadCode(code):
	codeBase = code.source
	print("----------------------------")
	print(codeBase)
	print("----------------------------")
	reset()


func next():
	step += 1
	print("-------------------------")
	print("Step " + str(step))
	print("-------------------------")
	if pointer >= codeBase.tokenArray.size():
		pointer = 0
	runLine()
	updateLabel()
	pointer += 1


func runLine():
	var line = codeBase.tokenArray[pointer]

	match line.command:
		"NOP":
			pass
		"JMP": instructionJump(line)
		"RET": instructionReturn()
		"MOV": instructionMOV(line)
		"RES": instructionRES()
		"ADD": instructionArithmetic(line.args[0], ArithmeticTypes.Add)
		"SUB": instructionArithmetic(line.args[0], ArithmeticTypes.Sub)
		"INC": instructionArithmetic(null, ArithmeticTypes.Inc)
		"DEC": instructionArithmetic(null, ArithmeticTypes.Dec)
		"MUL": instructionArithmetic(line.args[0], ArithmeticTypes.Mul)
		"DIV": instructionArithmetic(line.args[0], ArithmeticTypes.Div) 
		"AND": instructionArithmetic(line.args[0], ArithmeticTypes.And) 
		"OR": instructionArithmetic(line.args[0], ArithmeticTypes.Or) 
		"XOR": instructionArithmetic(line.args[0], ArithmeticTypes.Xor) 
		"STB": instructionBit(line.args[0], BitOpTypes.Set)
		"GTB": instructionBit(line.args[0], BitOpTypes.Get)
		"CLB": instructionBit(line.args[0], BitOpTypes.Clear)
		"SHL": instructionBit(line.args[0], BitOpTypes.ShiftLeft)
		"SHR": instructionBit(line.args[0], BitOpTypes.ShiftRight)
		"RTL": instructionBit(line.args[0], BitOpTypes.RotateLeft)
		"RTR": instructionBit(line.args[0], BitOpTypes.RotateRight)
		"GCN": cpu.acc = cpu.ctrl
		"SCN": cpu.ctrl = cpu.acc
		"CMP": instructionCompare(line.args[0], CompareType.Equal)
		"CNE": instructionCompare(line.args[0], CompareType.NotEqual)
		"CGT": instructionCompare(line.args[0], CompareType.Greater)
		"CLT": instructionCompare(line.args[0], CompareType.Lesser)
		"CGE": instructionCompare(line.args[0], CompareType.GreaterThan)
		"CLE": instructionCompare(line.args[0], CompareType.LesserThan)
		_:
			if line.command[line.command.length() - 1] == ":":
				if returnAddr.size() == 0:
					# Set pointer to end of the function
					#print("Executed Line: " + str(codeBase.tokenArray[pointer].line + 1) + " Pointer: "+ str(pointer) + " command: " +  codeBase.tokenArray[pointer].command)
					print("Moving pointer from: " + str(pointer) + "(Line: " + str(codeBase.tokenArray[pointer].line + 1 ) +  ") to: " + str(pointer + line.args[0]) + "(Line: " + str(codeBase.tokenArray[pointer + line.args[0]].line + 1 ) +  ")")
					pointer += line.args[0] 
			else:
				print("Invalid Command")

	if codeBase.size() > 0:
		Events.emit_signal("IdeCpuDebugLine", codeBase.tokenArray[pointer].line)
		print("Executed Line: " + str(codeBase.tokenArray[pointer].line + 1) + " Pointer: "+ str(pointer) + " command: " +  codeBase.tokenArray[pointer].command)

func instructionCompare(arg, mode): # mode->CompareType
	var result = false
	var compareValue = 0
	
	if Compiler.isAddress(arg):
		compareValue = getValueFromAddress(arg)
	else:
		compareValue = arg
		
	match mode:
		CompareType.Equal: if compareValue == cpu.acc: result = true
		CompareType.NotEqual: if compareValue != cpu.acc: result = true
		CompareType.Greater: if compareValue < cpu.acc: result = true
		CompareType.Lesser: if compareValue > cpu.acc: result = true
		CompareType.GreaterThan: if compareValue <= cpu.acc: result = true
		CompareType.LesserThan: if compareValue >= cpu.acc: result = true

	if result == false:
		pointer += 1

func instructionBit(bit, mode): # mode->BitOpTypes
	match mode:
		BitOpTypes.Set:
			cpu.acc |= 1 << bit
		BitOpTypes.Get:
			cpu.acc = (cpu.acc >> bit) & 1;
		BitOpTypes.Clear:
			cpu.acc &= ~(1 << bit)
		BitOpTypes.ShiftLeft:
			cpu.acc = (cpu.acc << bit) & 0xFF
		BitOpTypes.ShiftRight:
			cpu.acc = (cpu.acc >> bit) & 0xFF
		BitOpTypes.RotateLeft:
			cpu.acc = ((cpu.acc << bit) & 0xFF) | ((cpu.acc >> (8 - bit)) & 0xFF) 
		BitOpTypes.RotateRight:
			cpu.acc = ((cpu.acc >> bit) & 0xFF) | ((cpu.acc << (8 - bit)) & 0xFF)


func instructionJump(line):
	var offset = -1

	for label in codeBase.labels:
		if label.label == line.args[0]:
			offset = label.addrInTokenArray
			print("JMP: Jumping to " + str(offset))
			print("JMP: " + str(codeBase.tokenArray[offset]))
	
	if offset != -1:
		returnAddr.append(pointer) # Put pointer on the address stack
		pointer = offset # Jump to offset target

func instructionReturn():
	if returnAddr.size() > 0:
		pointer = returnAddr.pop_back() # One previous increment and one incoming
		print("RET: resetting pointer to: " + str(pointer) + "(Line: " + str(codeBase.tokenArray[pointer].line + 1 ) +  ")")
		print("RET: " + str(codeBase.tokenArray[pointer]))

func instructionRES():
	reset()
	pointer = -1 # Will be incremented afterwards

func instructionArithmetic(value, operator):
	var actualValue = 0

	if value != null:
		if Compiler.isAddress(value):
			actualValue = getValueFromAddress(value)
		else:
			# Number to acc
			actualValue = value
	
	match operator:
		ArithmeticTypes.Add:
			cpu.acc = (cpu.acc + actualValue) % 0xFF #Overflow protection
		ArithmeticTypes.Sub:
			cpu.acc = (cpu.acc - actualValue) & 0xFF #Underflow protection
		ArithmeticTypes.Mul:
			cpu.acc = (cpu.acc * actualValue) % 0xFF #Overflow protection
		ArithmeticTypes.Div:
			cpu.acc /= actualValue
		ArithmeticTypes.Inc:
			cpu.acc = (cpu.acc + 1) % 0xFF #Overflow protection
		ArithmeticTypes.Dec:
			cpu.acc = (cpu.acc - 1) & 0xFF #Underflow protection
		ArithmeticTypes.And:
			cpu.acc &= actualValue #Todo check?
		ArithmeticTypes.Or:
			cpu.acc |= actualValue #Todo check?
		ArithmeticTypes.Xor:
			cpu.acc ^= actualValue #Todo check?
		_:
			print("Unsupported Arithmetic Type")


func instructionMOV(line):
	var fromValue = 0
	var target = line.args[1]
	var arg = line.args[0]

	if not Compiler.isAddress(target):
		Global.Console.error("Target is not a valid address")
		return

	var targetIndex = int(target.lstrip(1))

	# Parsing from arg
	if Compiler.isAddress(arg):
		fromValue = getValueFromAddress(arg)
	else:
		fromValue = arg

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

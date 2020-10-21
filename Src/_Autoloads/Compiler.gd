extends Node


const valid_instructions = ["NOP", "JMP", "RET", "MOV", "ADD", "SUB", "INC", "DEC", "MUL", "DIV", "AND", "OR", "XOR", "STB", "GTB", "CLB", "SHL", "SHR", "RTL", "RTR", "CMP", "CNE", "CGT", "CLT", "CGE", "CLE"]


const valid_addresses = ["acc", "r0", "r1", "r2", "r3", "r4", "r5", "r6", "p0", "p1", "p2", "p3", "p4", "p5", "p6", "p7"]


const error_codes = ["ILI", "ILA", "MAV"]


const error_code_messages = ["Illegal instruction found: ", "Illegal address found: ", "Memory access violation: "]

const addresses = {
	ram = {
		start = 0,
		size = 16
	},
	rom = {
		start = 128,
		size = 32
	}
}


# Caution! This is only applicable on parsed data!
func isAddress(addr):
	if typeof(addr) == TYPE_STRING:
		return true
	return false

# Caution! This is only applicable on parsed data!
func isNumber(no):
	if typeof(no) == TYPE_INT:
		return true
	return false


func compile(source):
	var tokenizedSource = self.tokenize(source)
	
	if tokenizedSource.status == OK:
		var result = self.compileTokenizedSource(tokenizedSource)
		return result
	
	return tokenizedSource



# Basically tokenization
func tokenize(source):
	var result = {
		status = OK,
		tokenArray = [],
		labels = [],
		opCode = []
	}
	
	# Put the source in line arrays
	var codeBase = Array(source.split("\n", true, 0))
	
	# Parse Labels
	var regex = RegEx.new()
	regex.compile("^[^\\d;][^:]+(?=:)")
	for line in codeBase:
		var finding = regex.search(line)
		if finding != null:
			result.labels.append(finding.get_string())

	# Tokenize Lines
	for i in range(codeBase.size()):
		if codeBase[i].length() > 0:
			if codeBase[i][0] != ";" and codeBase[i][1] != ";":
				var tokens = tokenizeParseLine(codeBase[i], i, result.labels)
				if containsError(tokens.command):
					result.status = FAILED
				result.tokenArray.append(tokens)
	
	# Address Labels
	var newLabel = []
	for label in result.labels:
		for i in range(result.tokenArray.size()):
			if str(label) + ":" == result.tokenArray[i].command:
				newLabel.append({label = label, addrInTokenArray = i})
	result.labels = newLabel
	
	return result


func tokenizeParseLine(line, lineNo, labels):
	var parsedArgs = []
	var lineArray = line.split(" ", false, 0)
	
	# Illegal Instruction Check
	if not _isValidInstruction(lineArray[0]):
		var size = lineArray[0].length()
		# Check if its a label
		if lineArray[0][size - 1] == ":":
			var testLabel = lineArray[0].trim_suffix(":")
			if labels.find(testLabel) == -1:
				return {command = "ILI", line = lineNo, error = lineArray[0]}
		else:
			return {command = "ILI", line = lineNo, error = lineArray[0]}
	
	# Evaluate Arguments
	for index in range(1, lineArray.size()):
		var arg
		
		# Check if Number or Address
		if str(int(lineArray[index])) == lineArray[index]:
			arg = int(lineArray[index])
		else:
			# Sort out comments
			if lineArray[index][0] == ";":
				break
			
			# Illegal Argument Check
			if not _isValidAddress(lineArray[index]):
				if lineArray[index][0] == "$":
					var hex = "0x" + lineArray[index].trim_prefix("$")
					var addr = hex.hex_to_int()
					
					if ( addr >= addresses.ram.start and addr < addresses.ram.start + addresses.ram.size) \
						or ( addr >= addresses.rom.start and addr < addresses.rom.start + addresses.rom.size):
						#Valid Address
						#TODO plausibility check
						pass
					else:
						return {command = "MAV",  line = lineNo, error = lineArray[index]}
				else:

					if labels.find(lineArray[index]) == -1:
						return {command = "ILA",  line = lineNo, error = lineArray[index]}
			
			evaluateArguments()
			
			arg = lineArray[index]
		parsedArgs.append(arg)
	
	return {command = lineArray[0], line = lineNo, args = parsedArgs, opcode = 0}

func evaluateArguments():
	# TODO: evaluate args based on command
	print("todo evaluateArguments")
	pass


func containsError(instruction):
	for inst in error_codes:
		if inst == instruction:
			return true
	return false

func containsErrorReturnString(lineIndex, line):
	var retVal = [false]
	for index in range(error_codes.size()):
		if error_codes[index] == line.command:
			retVal[0] = true
			retVal.append("Line " + str(lineIndex) + ": " + error_code_messages[index] + "\"" + line.error + "\"")
	return retVal

func _isValidInstruction(instruction):
	for inst in valid_instructions:
		if inst == instruction:
			return true
	return false

func _isValidAddress(addr):
	for inst in valid_addresses:
		if inst == addr:
			return true
	return false

func _ready():
	pass

func _getRegisterIndex(reg):
	return valid_addresses.find(reg)

func compileTokenizedSource(source):
	var opCodes = ""
	
	for line in source.tokenArray:
		var code = "0000"
		
		match line.command:
			"NOP":
				code = "0000"
			"JMP":
				#TODO eval Line => addr
				for label in source.labels:
					if line.args[0] == label.label:
						code = "0" + "%03X" % label.addrInTokenArray
				if code == "0000":
					print("Error Address not found")
					
			"RET":
				code = "00FF"
			"MOV":
				if isNumber(line.args[0]):
					# 2xxy | MOV x(V) y(R/P) 
					code = "2" + "%02X" % line.args[0] + "%X" % _getRegisterIndex(line.args[1])
				else:
					# 10xy | MOV x(R/P) y(R/P)
					code = "10" +  "%X" % _getRegisterIndex(line.args[0]) + "%X" % _getRegisterIndex(line.args[1])
			"RES":
				code = "FFFF"
			"ADD":
				if isNumber(line.args[0]):
					# 31xx | ADD x(V)
					code = "31" + "%02X" % line.args[0]
				else:
					# 300x | ADD x(R/P)
					code = "300" +  "%X" % _getRegisterIndex(line.args[0])
			"SUB":
				if isNumber(line.args[0]):
					# 33xx | SUB x(V)
					code = "33" + "%02X" % line.args[0]
				else:
					# 320x | SUB x(R/P)
					code = "320" +  "%X" % _getRegisterIndex(line.args[0])
			"INC":
				code = "3400"
			"DEC":
				code = "3500"
			"MUL":
				if isNumber(line.args[0]):
					# 37xx | MUL x(V) 
					code = "37" + "%02X" % line.args[0]
				else:
					# 360x | MUL x(R/P)
					code = "360" +  "%X" % _getRegisterIndex(line.args[0])
			"DIV":
				if isNumber(line.args[0]):
					# 39xx | DIV x(V) 
					code = "39" + "%02X" % line.args[0]
				else:
					# 380x | DIV x(R/P)
					code = "380" +  "%X" % _getRegisterIndex(line.args[0])
			"AND":
				if isNumber(line.args[0]):
					# 3Bxx | AND x(V) 
					code = "3B" + "%02X" % line.args[0]
				else:
					# 3A0x | AND x(R/P)
					code = "3A0" +  "%X" % _getRegisterIndex(line.args[0])
			"OR":
				if isNumber(line.args[0]):
					# 3Dxx | OR x(V) 
					code = "3D" + "%02X" % line.args[0]
				else:
					# 3C0x | OR x(R/P)
					code = "3C0" +  "%X" % _getRegisterIndex(line.args[0])
			"XOR":
				if isNumber(line.args[0]):
					# 3Fxx | XOR x(V)
					code = "3F" + "%02X" % line.args[0]
				else:
					# 3E0x | XOR x(R/P)
					code = "3E0" +  "%X" % _getRegisterIndex(line.args[0])
			"STB":
				code = "400" + "%X" % line.args[0]
			"GTB":
				code = "410" + "%X" % line.args[0]
			"CLB":
				code = "480" + "%X" % line.args[0]
			"SHL":
				code = "420" + "%X" % line.args[0]
			"SHR":
				code = "430" + "%X" % line.args[0]
			"RTL":
				code = "440" + "%X" % line.args[0]
			"RTR":
				code = "450" + "%X" % line.args[0]
			"GCN":
				code = "4600"
			"SCN":
				code = "4700"
			"CMP":
				if isNumber(line.args[0]):
					# 51xx | CMP x(V) 
					code = "51" + "%02X" % line.args[0]
				else:
					# 500x | CMP x(R/P)
					code = "500" +  "%X" % _getRegisterIndex(line.args[0])
			"CNE":
				if isNumber(line.args[0]):
					# 53xx | CNE x(V)
					code = "53" + "%02X" % line.args[0]
				else:
					# 520x | CNE x(R/P)
					code = "520" +  "%X" % _getRegisterIndex(line.args[0])
			"CGT":
				if isNumber(line.args[0]):
					# 55xx | CGT x(V) 
					code = "55" + "%02X" % line.args[0]
				else:
					# 540x | CGT x(R/P)
					code = "540" +  "%X" % _getRegisterIndex(line.args[0])
			"CLT":
				if isNumber(line.args[0]):
					# 57xx | CLT x(V)
					code = "57" + "%02X" % line.args[0]
				else:
					# 560x | CLT x(R/P)
					code = "560" +  "%X" % _getRegisterIndex(line.args[0])
			"CGE":
				if isNumber(line.args[0]):
					# 59xx | CGE x(V)  
					code = "59" + "%02X" % line.args[0]
				else:
					# 580x | CGE x(R/P)
					code = "580" +  "%X" % _getRegisterIndex(line.args[0])
			"CLE":
				if isNumber(line.args[0]):
					# 5Bxx | CLE x(V)
					code = "5B" + "%02X" % line.args[0]
				else:
					# 5A0x | CLE x(R/P)
					code = "5A0" +  "%X" % _getRegisterIndex(line.args[0])
			_:
				
				if line.command[line.command.length() - 1] == ":":
					var startLine = -1
					
					# Get own start address
					for label in source.labels:
						if label.label == line.command.trim_suffix(":"):
							startLine = label.addrInTokenArray
							break
					
					if startLine == -1:
						print("Error: Label not found")
						return {status = FAILED, source = source}
		
					var length = -1
					
					# Loop source starting at line looking for RET statement
					for i in range(startLine + 1, source.tokenArray.size()):
						var command = source.tokenArray[i].command
						
						if command == "RET":
							length = i - startLine
							break
						elif command[command.length() - 1] == ":":
							print("RET not found before new label start")
							return {status = FAILED, source = source}
					
					if length > 0:
						code = "F0" + "%02X" % length
						line.args.append(length)
					else:
						print("RET not found")
						return {status = FAILED, source = source}
					
				else:
					print("Illegal command found.")
				
		
		opCodes += code
		line.opcode = code
	source.opCode = opCodes
	return {status = OK, source = source}

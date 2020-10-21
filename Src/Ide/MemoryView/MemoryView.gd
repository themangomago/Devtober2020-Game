extends ColorRect

const labelStart = [ \
"[color=#a7c4fa]0x00[/color] [color=#ffeca0]RAM[/color]  ",
"[color=#a7c4fa]0x80[/color] [color=#ff7084]ROM[/color]  ",
"[color=#a7c4fa]0x90[/color] [color=#ff7084]ROM[/color]  ",
]

var lastRamLine = null


func updateMemoryView(cpuState):
	var string = ""
	string += drawLines(cpuState.ram, cpuState.rom)
	$Label.bbcode_text = string
	


func drawLines(ramLine, romLine):
	var row0 = labelStart[0]
	var row1 = labelStart[1]
	var row2 = labelStart[2]
	
	for i in range(16):
		row0 += str(ramLine[i]).pad_zeros(2) + "  "
		row1 += str(romLine[i]).pad_zeros(2) + "  "
		row2 += str(romLine[i + 16]).pad_zeros(2) + "  "
	
	return row0 + "\n" + row1 + "\n" + row2

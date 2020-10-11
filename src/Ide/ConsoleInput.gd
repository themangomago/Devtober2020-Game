extends TextEdit

const COLOR_INSTRUCTION = Color("#ec2658")
const COLOR_COMMENT = Color("#a6e22e")
const COLOR_LABEL = Color("#66d9ef")
const COLOR_NUMBERS = Color("#ae81ff")

func registerKeywords():
	for keyword in Compiler.valid_instructions:
		self.add_keyword_color(keyword, COLOR_INSTRUCTION)

	#self.add_color_region("$", " ", COLOR_NUMBERS, false)
	self.add_color_region(";", "", COLOR_COMMENT, true)
	
	self.add_keyword_color("acc", COLOR_LABEL)
	for i in range(8):
		self.add_keyword_color("p"+str(i), COLOR_LABEL)
		self.add_keyword_color("r"+str(i), COLOR_LABEL)

	# Numbercolor in theme
	

func _ready():
	registerKeywords()
	Global.Console.add("IDE Started..")
	#self.set_highlight_current_line(true)
	Events.connect_signal("IdeCpuDebugLine", self, "updateDebugLine")
 
func updateDebugLine(line):
	$LineCursor.position = Vector2(0, 20*line)

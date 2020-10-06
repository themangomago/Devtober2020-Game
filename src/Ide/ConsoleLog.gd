extends TextEdit


var currentLine = 0

const COLOR_ERROR = Color("#9b102d")
const COLOR_WARNING = Color("#e5a91f")

var logText = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.Console = self
	self.add_color_region("?", "", COLOR_ERROR, true)
	self.add_color_region("!", "", COLOR_WARNING, true)

func error(text):
	add("? Error: " + str(text))

func warning(text):
	add("! Warning: " + str(text))

func add(text):
	var time = OS.get_time()
	var timestamp = str(time.hour).pad_zeros(2) + ":" + str(time.minute).pad_zeros(2) + ":" + str(time.second).pad_zeros(2)
	print(text)
	logText += timestamp + " - " + text + "\n"
	self.set_text(logText)
	

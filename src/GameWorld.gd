extends Node2D


func setCamera():
	$Camera2D.make_current()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set Camera Limits
	$Camera2D.limit_left = $LimitStart.position.x
	$Camera2D.limit_top = $LimitStart.position.y
	$Camera2D.limit_right = $LimitEnd.position.x
	$Camera2D.limit_bottom = $LimitEnd.position.y

extends Node2D


func setCamera():
	$Camera2D.make_current()

func _ready():
	# Set Camera Limits
	$Camera2D.limit_left = $LimitStart.position.x
	$Camera2D.limit_top = $LimitStart.position.y
	$Camera2D.limit_right = $LimitEnd.position.x
	$Camera2D.limit_bottom = $LimitEnd.position.y
	add_child($NightOver/Tween)
	print($NightOver.color)

func _on_ExitArea_body_entered(body):
	if body.is_in_group("Player"):
		$NightOver/Tween.stop_all()
		$NightOver/Tween.interpolate_property($NightOver, "color", $NightOver.color, Color(0.129412, 0.129412, 0.137255, 1.0), 0.5, Tween.TRANS_LINEAR)
		$NightOver/Tween.start()


func _on_ExitArea_body_exited(body):
	if body.is_in_group("Player"):
		$NightOver/Tween.stop_all()
		$NightOver/Tween.interpolate_property($NightOver, "color", $NightOver.color, Color(0.129412, 0.129412, 0.137255, 0.0), 0.5, Tween.TRANS_LINEAR)
		$NightOver/Tween.start()

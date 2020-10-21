extends Node2D

enum DoorStateType {closed, opening, open, closing }
var doorState = DoorStateType.closed

func _process(delta):
	#$Label.set_text(str(doorState))
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"open":
			doorState = DoorStateType.open
			$StaticBody2D/CollisionShape2D.set_disabled(true)
		"close":
			doorState = DoorStateType.closed
			$StaticBody2D/CollisionShape2D.set_disabled(false)
		_:
			#idle
			pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		if doorState == DoorStateType.closed:
			$AnimationPlayer.play("open")
			doorState = DoorStateType.opening


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		if doorState == DoorStateType.open:
			$AnimationPlayer.play("close")
			doorState = DoorStateType.closing

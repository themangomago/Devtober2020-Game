extends KinematicBody2D

enum animStateType {idle = 0, up, down, left, right}


const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500
const ANIM_IDLE_TRANSITION = 20

var velocity = Vector2.ZERO
var closeObject = null

func _ready():
	$AnimationPlayer.play("idle")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()
	
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	updateAnimation()
	$Label.set_text(str(velocity))
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("ui_accept"):
		if closeObject != null:
			if closeObject.objectType == Types.WorldObjectTypes.PlayerDesk:
				Events.emit_signal("CameraSwitch", Types.CameraTypes.Computer)

func updateAnimation():
	var desiredAnimation = "idle"
	var absX = abs(velocity.x)
	var absY = abs(velocity.y)
	var maxSpeed = max(absX, absY)
	
	if maxSpeed > ANIM_IDLE_TRANSITION:
		if absY > absX:
			if velocity.y > 0: 
				#Down
				desiredAnimation = "down"
			else:
				#UP
				desiredAnimation = "up"
		else:
			if velocity.x > 0: 
				#Right
				desiredAnimation = "right"
			else:
				#Left
				desiredAnimation = "left"
	
	if $AnimationPlayer.current_animation != desiredAnimation:
		$AnimationPlayer.play(desiredAnimation)

func addObject(object):
	closeObject = object


func removeObject(object):
	if closeObject == object:
		closeObject = null

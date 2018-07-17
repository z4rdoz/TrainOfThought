extends KinematicBody2D

onready var Constants = preload("Constants.gd")

const UP = Vector2(0, -1)
const GRAVITY = 10
const JUMP_HEIGHT = -200
const ACCELERATION = 50
const MAX_SPEED = 100
const CLIMB_SPEED = 50

var _motion = Vector2()
var _canClimb = false setget set_canClimb
var _canJump = true;
var _isClimbing = false
var _climbX = 0.0 setget set_climbX

var playerControls = {}
	
func resetPlayerControls():
	playerControls = {
		jump = false,
		up = false,
		down = false,
		right = false,
		left = false
	}

func _ready():
	set_safe_margin(0.05)
	resetPlayerControls()

#func _unhandled_input(event):	
#	if event.is_action("up"):
#		playerControls.up = event.is_pressed()
#
#	if event.is_action("down"):
#		playerControls.down =  event.is_pressed()
#
#	if event.is_action("left"):
#		playerControls.left = event.is_pressed()
#
#	if event.is_action("right"):		
#		playerControls.right =  event.is_pressed()
#
#	if not event.is_pressed():
#		print('released')
#	playerControls.jump = false
#	if event.is_action("A"):
#		if event.is_pressed():		
#			if _canJump:				
#				playerControls.jump = true	
#				_canJump = false			
#		else:
#			_canJump = true

func _physics_process(delta):
	#These support holding down
	playerControls.right = Input.is_action_pressed("right")
	playerControls.left = Input.is_action_pressed("left")
	playerControls.down = Input.is_action_pressed("down")
	playerControls.up = Input.is_action_pressed("up")
	playerControls.jump = Input.is_action_just_pressed("A")
	
	var friction = false
	var animation = "Idle"
	
	#An attempt to make it so as you climb through platforms you can walk left and right if you're near them
	#This has so far failed
#	var space_rid = get_world_2d().space
#	var space_state = get_world_2d().direct_space_state
#	var extents = $CollisionBody2D.get_shape().get_extents()
#	var collisionBody2DBottom = to_global(Vector2($CollisionBody2D.position.x, 
#		$CollisionBody2D.position.y + extents.y-1))
#	var result = space_state.intersect_ray(collisionBody2DBottom, 
#		Vector2(collisionBody2DBottom.x,collisionBody2DBottom.y+2), [self], collision_mask)	
#
	if is_on_floor():	
		_isClimbing = false
	
	if playerControls.right:
		$Sprite.flip_h = false
	elif playerControls.left:
		$Sprite.flip_h = true	
	
	if _canClimb:	
		if playerControls.down or playerControls.up:			
			_isClimbing = true
	else:
		_isClimbing = false
	
	#main logic
	if _isClimbing:			
		_motion.y = 0	
		_motion.x = 0
		set_position(Vector2(_climbX-16, get_position().y))
		animation = "Idle"		
		if playerControls.jump:
			_isClimbing = false
		if playerControls.up:			
			_motion.y -= CLIMB_SPEED
		elif playerControls.down:			
			_motion.y += CLIMB_SPEED
	else:		
		_motion.y += GRAVITY		
	
		if playerControls.right:		
			_motion.x = min(_motion.x + ACCELERATION, MAX_SPEED)		
			animation = "Run"
		elif playerControls.left:
			_motion.x = max(_motion.x - ACCELERATION, -MAX_SPEED)				
			animation = "Run"
		else:						
			friction = true
		
		if is_on_floor():				
			if playerControls.jump:
				_motion.y = JUMP_HEIGHT						
			if friction:
				_motion.x = lerp(_motion.x, 0, 0.5)				
		else:
			if _motion.y < 0:
				animation = "Jump"
			else:
				animation = "Fall"
			if friction:
				_motion.x = lerp(_motion.x, 0, 0.2)
	
	_motion = move_and_slide(_motion, UP)		
	
	#collisions	
	set_collision_mask_bit(Constants.Layers.Platform, not playerControls.down)
	
	if $AnimationPlayer.current_animation != animation:
		$AnimationPlayer.play(animation)

	#$Camera2D.global_position.x = floor($Camera2D.global_position.x)
	

func _draw():
	pass
#	var extents = $CollisionBody2D.get_shape().get_extents()
#	var ctran = Vector2($CollisionBody2D.position.x, 
#		$CollisionBody2D.position.y + extents.y)		
#	draw_line(ctran, Vector2(ctran.x, ctran.y-5), Color(255,0,0), 1)
	
func set_canClimb(value):	
	_canClimb = value
	
func set_climbX(value):
	_climbX = value

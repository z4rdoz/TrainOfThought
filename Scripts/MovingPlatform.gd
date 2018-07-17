extends Path2D

tool

export(float) var speed = 1
export(int) var width = 2 setget set_width
export(bool) var moveInEditor = false

var _generated
#var _follow
#onready for _follow didn't work. Not sure why
var _follow
var _reverse = false
onready var _spriteLeft = $"Sprite-Left"
onready var _spriteRight = $"Sprite-Right"
onready var _spriteMid = $"Sprite-Mid"
onready var _collision = $PathFollow2D/StaticBody2D/CollisionShape2D

func _ready():
#	var newCurve = get_curve()
#	set_curve(newCurve.duplicate())
	pass

func _process(delta):
	#not sure why onready doesn't work for this variable
	var curve = get_curve()
	if curve == null:		
		set_width(width)
		return
	var pointCount = get_curve().get_point_count()
	if pointCount == 0:
		set_width(width)
		return
	if _follow == null:		
		if has_node("PathFollow2D"):
			_follow = $PathFollow2D	
			_follow.set_offset(0)
			set_width(width)
		return
		
	if pointCount == 1 or (Engine.is_editor_hint() and not moveInEditor):		
		_follow.set_offset(0)		
	else:		
		var adjSpeed = speed#1/float(pointCount)*speed		
		var unitOffset = _follow.get_unit_offset()
		var pixelOffset = _follow.get_offset()
		if unitOffset < 0:
			_reverse = false;
		if _reverse:
			pixelOffset -= adjSpeed * delta
		else:
			pixelOffset += adjSpeed * delta		
		if unitOffset > 1:
			if get_curve().get_point_position(0) == get_curve().get_point_position(pointCount-1):
				_follow.set_unit_offset(0)
			else:
				_reverse = true
		_follow.set_offset(pixelOffset)
		
		#print(_follow.get_unit_offset())
	
	
func set_width(value):
	if (_collision == null or _follow == null):
		return	
	
	if _generated != null:
		_follow.remove_child(_generated)		
			
	_generated = Area2D.new()
	_generated.set_name("_generated")
	_follow.add_child(_generated)
	
	if value < 2:
		value = 2
	
	width = value
	#this is plus 1 because the end tiles are half, hence they make up 1
	var workingWidth = width + 1
	
	#keep adding sprites for as long as the moving platform is
	var platformSprite = _spriteLeft.duplicate()
	for i in range(0,workingWidth):
		if i + 1 == workingWidth:
			platformSprite = _spriteRight.duplicate()
		elif i > 0:
			platformSprite = _spriteMid.duplicate()
		platformSprite.move_local_x(i*16)
		platformSprite.visible = true
		_generated.add_child(platformSprite)	
	
	_generated.move_local_x(float(-width)*16/2)
	#change the _collision to match
	_collision.shape.extents = Vector2(float(width)/2*16, 2)	


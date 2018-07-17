extends Node

onready var Constants = preload("Constants.gd")

var _player
var _areas = []
var _activeArea
var _newArea
var _screenSize
var _camera 
var _reachedNewLimits = false
var _newLimits = {}
var _limitLerp = 0.0
var _movedOnce = false

func _ready():
	_camera = $Camera2D
	_screenSize = _camera.get_viewport_rect().size
	var children = get_children()
	var firstChild
	for child in children:
		if child.is_class("Area2D"):
			if firstChild == null:
				firstChild = child
			_areas.append(child)
			child.set_collision_mask(0)
			child.set_collision_layer(0)
			child.set_collision_mask_bit(Constants.Layers.Player, true)
			child.set_collision_layer_bit(Constants.Layers.Solid, true)
			child.connect("body_entered", self, "_area2d_body_entered", [child])
			child.connect("body_exited", self, "_area2d_body_exited", [child])
	if firstChild != null:
		makeActiveArea(firstChild)

func _process(delta):
	if _player == null:
		_player = get_tree().get_root().find_node("Player", true, false)			
	
	var g = _camera.global_position
	var moveTo = _player.global_position		
	#_camera.set_global_position(lerp(g, moveTo, 0.1))
	_camera.set_global_position(moveTo)	
	
	if not _movedOnce:
		_camera.limit_left = _newLimits.left
		_camera.limit_right = _newLimits.right
		_camera.limit_top = _newLimits.top
		_camera.limit_bottom = _newLimits.bottom
		_movedOnce = true
	elif _limitLerp < 1:		
		get_tree().paused = true
		#1 - 3, 2 - 6, 3 - 9
		var rate = 1.5 
		_limitLerp += delta*rate
		if _limitLerp > rate*3/10:
			_limitLerp = 1
		var lerpLeft = floor(lerp(_camera.limit_left, _newLimits.left, _limitLerp))
		var lerpRight = ceil(lerp(_camera.limit_right, _newLimits.right, _limitLerp))
		var lerpTop = lerp(_camera.limit_top, _newLimits.top, _limitLerp)
		var lerpBtm = lerp(_camera.limit_bottom, _newLimits.bottom, _limitLerp)
		
		_camera.limit_left = lerpLeft
		_camera.limit_right = lerpRight
		_camera.limit_top = lerpTop
		_camera.limit_bottom = lerpBtm
	else:
		get_tree().paused = false

func _area2d_body_exited(body, area):
	if body.name != "Player":
		return
	if area ==_activeArea:
		makeActiveArea(_newArea)

func _area2d_body_entered(body, area):
	if body.name != "Player":
		return
	if _activeArea == null:
		makeActiveArea(area)
	_newArea = area
	
func makeActiveArea(area):
	_newLimits = {}
	var polygon = area.get_child(0).polygon
	for i in range(polygon.size()):
		var point = polygon[i]
		point.x = point.x + area.get_child(0).get_global_position().x
		point.y = point.y + area.get_child(0).get_global_position().y
		if not _newLimits.has("right") or point.x > _newLimits.right:
			_newLimits.right = point.x
		elif not _newLimits.has("left") or point.x < _newLimits.left:
			_newLimits.left = point.x
		if not _newLimits.has("top") or point.y < _newLimits.top:
			_newLimits.top = point.y
		elif not _newLimits.has("bottom") or point.y > _newLimits.bottom:
			_newLimits.bottom = point.y
#	_camera.limit_left = _newLimits.left
#	_camera.limit_right = _newLimits.right
#	_camera.limit_top = _newLimits.top
#	_camera.limit_bottom = _newLimits.bottom	
	_activeArea = area
	_limitLerp = 0.0
	_reachedNewLimits = false
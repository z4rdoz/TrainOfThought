extends Node2D

var _pathArray = []
var _drawer
var _player
var _intersectionPoints = {}
var _activePath
var _switchToPath
var _trainPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	_drawer = Node2D.new()
	
	self.add_child(_drawer)
	for child in children:
		if child.is_class("Path2D"):
			_pathArray.append(child)
	set_process(true)
	
	for path in _pathArray:
		var currentPath = path
		var currentPoints = currentPath.get_curve().get_baked_points()
		for path2 in _pathArray:
			if path2 == currentPath:
				continue
			var comparePoints = path2.get_curve().get_baked_points()
			for i in range(0, currentPoints.size()-1):
				for i2 in range(0, comparePoints.size()-1):					
					var currentPoint = currentPoints[i]
					var comparePoint = comparePoints[i2]
					var currentPoint2 = currentPoints[i+1]
					var comparePoint2 = comparePoints[i2+1]
					currentPoint.x += currentPath.get_position().x
					currentPoint.y += currentPath.get_position().y
					comparePoint.x += path2.get_position().x
					comparePoint.y += path2.get_position().y
					currentPoint2.x += currentPath.get_position().x
					currentPoint2.y += currentPath.get_position().y
					comparePoint2.x += path2.get_position().x
					comparePoint2.y += path2.get_position().y
					var inter = DoLinesIntersect(currentPoint.x, currentPoint.y, 
						currentPoint2.x, currentPoint2.y, 
						comparePoint.x, comparePoint.y, 
						comparePoint2.x, comparePoint2.y)
					if inter != null:
						_intersectionPoints[inter] = [currentPath, path2]


func _draw():		
	_trainPosition = null
	var pointArrays = []
	for path in _pathArray:
		if _activePath == null:
			_activePath = path	
		var pointArray = []
		for p in path.get_curve().get_baked_points():
			p.x += path.get_position().x
			p.y += path.get_position().y
			pointArray.append(p)	
			
		pointArrays.append(pointArray)	
		var color
		if path == _activePath:
			color = Color(0.0, 1.0, 0.0)
		else:
			color = Color(0.0, 0.3, 0.4)
		self.draw_polyline(PoolVector2Array(pointArray), color, 2)
	
	_switchToPath = null
	if _activePath != null and _player != null:
		var lastPoint = null
		var secondToLastPoint = null
		var playerX = _player.get_global_position().x + 16
		var curvePoints = _activePath.get_curve().get_baked_points()
		for p in curvePoints:			
			p.x += _activePath.get_position().x
			p.y += _activePath.get_position().y	
			if p.x > playerX and lastPoint != null:
				break
			secondToLastPoint = lastPoint
			lastPoint = p
			
			
		if lastPoint != null:
			var isIntersecting = false
			var intersectionPoint
			for	p in _intersectionPoints:
				if p.distance_to(lastPoint) <= 8:
					isIntersecting = true
					intersectionPoint = p
					break
			if isIntersecting:
				draw_circle(lastPoint, 4, Color(1.0, 1.0, 0.0))
				var paths = _intersectionPoints[intersectionPoint]
				var path = paths[0]
				if path == _activePath:
					path = paths[1]
				_switchToPath = path
			else:
				draw_circle(lastPoint, 4, Color(1.0,0, 0.0))	
		
		_trainPosition = lastPoint
	
func _process(delta):
	if _player == null and get_parent().find_node("Player"):
		_player = get_parent().get_node("Player")
	update()
	if Input.is_action_just_pressed("A"):
		if _switchToPath != null:
			_activePath = _switchToPath
			_switchToPath = null
	

func _physics_process(delta):
	if _trainPosition != null:
		$Train.set_global_position(_trainPosition)
		
	if _player == null:
		return
	var playerY = _player.get_global_position().y + 32 
	var trainY = $Train.get_global_position().y + 2
	if playerY < trainY:
		$Train.set_collision_mask_bit(2, true)
	else:
		$Train.set_collision_mask_bit(2, false)
	pass
	

#from http://paulbourke.net/geometry/pointlineplane/
static func DoLinesIntersect(l1x1, l1y1, l1x2, l1y2, l2x1, l2y1, l2x2, l2y2):
	var d = (l2y2 - l2y1) * (l1x2 - l1x1) -(l2x2 - l2x1) * (l1y2 - l1y1)
	#n_a and n_b are calculated as seperate values for readability
	var n_a = (l2x2 - l2x1) * (l1y1 - l2y1) - (l2y2 - l2y1) * (l1x1 - l2x1)
	var n_b = (l1x2 - l1x1) * (l1y1 - l2y1) - (l1y2 - l1y1) * (l1x1 - l2x1)
#     Make sure there is not a division by zero - this also indicates that
#     the lines are parallel.  
#     If n_a and n_b were both equal to zero the lines would be on top of each 
#     other (coincidental).  This check is not done because it is not 
#     necessary for this implementation (the parallel check accounts for this).
	if d == 0:
		return null
	#     // Calculate the intermediate fractional point that the lines potentially intersect.
	var ua = n_a / d
	var ub = n_b / d
	#     // The fractional point will be between 0 and 1 inclusive if the lines
	#     // intersect.  If the fractional calculation is larger than 1 or smaller
	#     // than 0 the lines would need to be longer to intersect.
	if (ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1):    
		var ret = Vector2(0,0) 
		ret.x = l1x1 + (ua * (l1x2 - l1x1))
		ret.y = l1y1 + (ua * (l1y2 - l1y1))
		return ret
	return null
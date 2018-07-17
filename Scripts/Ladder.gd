"""
tool

extends Area2D

export(int) var height = 2 setget set_height
var _generated
var _spriteTop
var _spriteMiddle
var _spriteBottom
var _collision

func _ready():
	if _generated == null:
		set_height(2)
	pass

func _process(delta):
	
	pass

func set_height(value):
	if (not has_node("Sprite-Top") 
		or not has_node("Sprite-Bottom") 
		or not has_node("Sprite-Middle")):
		return

	if _spriteTop == null:
		_spriteTop = $"Sprite-Top"
		_spriteMiddle = $"Sprite-Middle"
		_spriteBottom = $"Sprite-Bottom"
		_collision = $CollisionShape2D
		
	if _generated != null:
		remove_child(_generated)		
			
	_generated = Area2D.new()
	_generated.set_name("_generated")
	add_child(_generated)
	
	#ladders need at least a top and bottom
	if value < 2:
		value = 2
	
	height = value	

	#keep adding sprites for as long as the ladder is
	var ladderSprite = _spriteBottom.duplicate()
	for i in range(0,height):
		if i + 1 == height:
			ladderSprite = _spriteTop.duplicate()
		elif i > 0:
			ladderSprite = _spriteMiddle.duplicate()
		ladderSprite.move_local_y(i*-16)
		ladderSprite.visible = true
		_generated.add_child(ladderSprite)	
			
	#change the collision to match
	_collision.shape.extents = Vector2(2, float(height)/2*16-12)
	_collision.position = Vector2(0, float(height)/2*-16)
"""

#The above code is when the sprite was built into the ladder class. 
#I don't like that, I think the ladder should just be the collision
#To restore the above code, re-add three sprites, 'Sprite-Top', 'Sprite-Middle', 'Sprite-Bottom'

tool

extends Area2D

export(int) var height = 2 setget set_height

func set_height(value):	
	if value < 2:
		value = 2
	
	height = value	

	#change the collision to match
	if has_node("CollisionShape2D"):
		$CollisionShape2D.shape.extents = Vector2(2, float(height)*16/2)
		$CollisionShape2D.position = Vector2(0, float(height)*16/2)

func _on_Ladder_area_shape_entered(area_id, area, area_shape, self_shape):	
	if area.get_name() == "PlayerCenter":			
		area.get_parent().set_canClimb(true)		
		area.get_parent().set_climbX(self.position.x)

func _on_Ladder_area_shape_exited(area_id, area, area_shape, self_shape):
	if area.get_name() == "PlayerCenter":
		area.get_parent().set_canClimb(false)	

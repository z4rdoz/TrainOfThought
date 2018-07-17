extends Node2D

export(float) var CrumbleTime = 0.75

var _crumbleTime
var _minimumIncrement = 30
var _crumbleStart
var _startTime

func _ready():
	_crumbleTime = CrumbleTime*1000
	pass
	
func _physics_process(delta):
	if _crumbleStart != null:
		crumble(delta)

func crumble(delta):
	var elapsed = OS.get_ticks_msec() - _startTime	
	if elapsed >= _crumbleTime:
		$Sprite.visible = false
		$CollisionShape2D.disabled = true
		queue_free()
	elif elapsed >= 2*_crumbleTime/3:
		$Sprite.region_rect.position.x = 48
	elif elapsed >= _crumbleTime/3:
		$Sprite.region_rect.position.x = 32
		pass
		
#	else:
#		#really just fudging the logic here
#		#var increment = max(delta*4*(elapsed/1000), 0.2)
#		var increment = delta*25
#		_crumbleStart += increment
#		$Sprite.visible = abs(sin(_crumbleStart)) > 0.5


func _on_Area2D_body_entered(body):
	if _crumbleStart == null:
		_crumbleStart = 0.0
		_startTime = OS.get_ticks_msec()

extends Area2D

export var message = "..."

func _ready():
	var tempMsg = message
	$Label.visible = false
	$Label.text = tempMsg	
	$Label.get_line_count()
	pass

func _on_Area2D_body_entered(body):
	if body.name == "Player":		
		$Label.visible = true	
		$Label.rect_size.y = $Label.get_line_count()*8
		$Label.rect_position.y = -15 - $Label.get_line_count()*8

func _on_NPC_body_exited(body):
	$Label.visible = false

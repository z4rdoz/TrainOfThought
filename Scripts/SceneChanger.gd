extends Node

export(String, FILE, "*.tscn") var scene_file

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_area2d_body_entered")

func _area2d_body_entered(body):
	if body.name == "Player":
		get_node("/root/global").goto_scene(scene_file)	

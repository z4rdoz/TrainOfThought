tool
extends Node

export(bool) var reset = false setget onReset

#config
export var tileSize = 16
export(String, FILE, "*.png") var tileSprite

func _ready():
	pass

func onReset(isTriggered):
	if tileSprite == null:
		print('tile sprite is null')
		return
	
	if (isTriggered):
		reset = false
	var sprite = load(tileSprite)
	var w = sprite.get_width() / tileSize
	var h = sprite.get_height() / tileSize
	
	var name = 0
	
	for y in range(h):
		for x in range(w):
			var spriteImage = sprite.get_data().get_rect(Rect2(x*tileSize, y*tileSize,tileSize,tileSize))
			spriteImage.lock()
			var hasPixel = false
			for x2 in range(tileSize):
				if hasPixel:
					break
				for y2 in range(tileSize):
					if spriteImage.get_pixel(x2,y2).a != 0:
						hasPixel = true
						break			
						
			if hasPixel:
				var tile = Sprite.new()
				add_child(tile)
				tile.set_owner(self)
				tile.set_name(str(name))
				tile.set_texture(sprite)
				tile.set_region(true)
				tile.set_region_rect(Rect2(x*tileSize, y*tileSize, tileSize, tileSize))
				tile.position = Vector2(x*tileSize+tileSize/2, y*tileSize+tileSize/2)
				name += 1
				
			
			
			
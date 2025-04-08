extends TileMapLayer

func _process(_delta):
	if Global.can_noclip:
		self.modulate = Color(255, 255, 255, 0.33)
	else:
		self.modulate = Color(255, 255, 255, 1)

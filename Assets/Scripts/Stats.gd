extends Node2D

func _process(_delta):
	$Coins2.text = str(Global.CURRENCY)
	$Collectibles2.text = str(Global.collectibles_got.size()) + "/5"

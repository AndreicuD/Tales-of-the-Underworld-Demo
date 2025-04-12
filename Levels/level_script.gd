extends Node2D

var collectible : bool = false

@export_enum("Menu", "Underground") var world : int

@export_category("Unlockables")
@export var gravi_boots : bool = true
@export var noclip : bool = true

func _ready():
	Global.change_music(world)
	Global.WORLD = world
	Global.can_change_gravity = gravi_boots
	Global.set_can_noclip(noclip)

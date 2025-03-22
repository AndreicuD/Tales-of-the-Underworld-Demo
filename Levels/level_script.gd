extends Node2D

@export var gravi_boots : bool = true
@export var altceva : bool = true

func _ready():
	Global.can_change_gravity = gravi_boots

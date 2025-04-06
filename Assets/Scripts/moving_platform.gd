extends CharacterBody2D

@export_enum("2", "3") var platform_size: int
@onready var coll_2 = $"2"
@onready var coll_3 = $"3"

func _ready():
	$AnimatedSprite2D.play("2")
	coll_2.disabled = false
	coll_3.disabled = true
	if(platform_size == 1):
		$AnimatedSprite2D.play("3")
		coll_2.disabled = true
		coll_3.disabled = false

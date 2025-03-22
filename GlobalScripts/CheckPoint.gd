extends Area2D

@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D
@export_enum("down", "up") var checkpoint_gravity: String = "down"

func _on_body_entered(_body):
	animatedSprite.play("activated")
	Global.HEALTH = Global.MAX_HEALTH
	Global.set_spawn_point(self.global_position, self.checkpoint_gravity)

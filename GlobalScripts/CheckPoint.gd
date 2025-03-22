extends Area2D

@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D
@export_enum("down", "up") var checkpoint_gravity: String = "down"

@export var gravi_boots : bool = true

func deactivate():
	animatedSprite.play("normal")

func _on_body_entered(_body):
	for checkpoint in get_tree().get_nodes_in_group("Checkpoint"):
		checkpoint.deactivate()

	animatedSprite.play("activated")
	Global.set_health(Global.get_max_health())
	Global.set_spawn_point(self.global_position, self.checkpoint_gravity)
	Global.can_change_gravity = gravi_boots

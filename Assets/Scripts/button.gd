extends Area2D

@export var connect_to : StaticBody2D
var pressing_bodies : Array[Node2D]

func _on_body_entered(body):
	pressing_bodies.append(body)
	$AnimatedSprite2D.play("pressed")
	if connect_to:
		connect_to.open()

func _on_body_exited(body):
	pressing_bodies.erase(body)
	if pressing_bodies.is_empty():
		if connect_to:
			connect_to.close()
		$AnimatedSprite2D.play("not_pressed")

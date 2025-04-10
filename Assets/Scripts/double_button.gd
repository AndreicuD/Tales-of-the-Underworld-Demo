extends Area2D

@export var connect_to : StaticBody2D
var pressing_bodies : Array[Node2D]

func _process(_delta):
	if connect_to:
		if pressing_bodies.size() >= 2:
			connect_to.open()
		else:
			connect_to.close()

func _on_body_entered(body):
	pressing_bodies.append(body)
	$AnimatedSprite2D.play("pressed")

func _on_body_exited(body):
	pressing_bodies.erase(body)
	if pressing_bodies.is_empty():
		$AnimatedSprite2D.play("not_pressed")

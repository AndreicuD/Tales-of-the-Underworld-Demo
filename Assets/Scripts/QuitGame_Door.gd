extends Area2D

@onready var anim : AnimatedSprite2D = $DoorSprite
@onready var PopUp : CanvasLayer = $"PopUp"
var is_active : bool = false
var player
var is_opened : bool = false

func _ready():
	anim.play("closed_no_key")

func _process(_delta):
	if Input.is_action_just_pressed("Interact") && is_active:
		if !is_opened:
			anim.play("opened")
			is_opened = true
		elif is_opened:
			PopUp.visible = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		is_active = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		is_active = false
		player = null
		PopUp.set_visible(false)

func _on_button_pressed():
	PopUp.set_visible(false)
	get_tree().quit()

func _on_no_button_pressed():
	PopUp.set_visible(false)

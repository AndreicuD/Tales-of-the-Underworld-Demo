extends Node2D

@export_enum("Gravi-Boots", "Quantum Cloak") var item: String = "Gravi-Boots"
@export var font_size : int = 56

@export var button_text : String = "Nice"

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var ExclMark : Sprite2D = $"Exclamation Mark"
@onready var ExclMarkAnim : AnimationPlayer = $"Exclamation Mark/AnimationPlayer"

@onready var PopUp : CanvasLayer = $"PopUp"
@onready var PopUpText : Label = $"PopUp/Text"
@onready var down_button : Button = $"PopUp/Ok Button"

var is_active : bool

func _ready():
	var text = "You just found the " + item + "!"
	PopUpText.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	PopUpText.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	PopUpText.set_text(text)
	PopUpText.add_theme_font_size_override("font_size", font_size)
	down_button.set_text(button_text)

func _process(_delta):
	if is_active:
		ExclMark.set_visible(true)
		ExclMarkAnim.play("Up-Down")
		if Input.is_action_just_pressed("Interact"):
			PopUp.set_visible(true)
			anim_sprite.play("opened")

			if(item == 'Gravi-Boots'):
				Global.can_change_gravity = true
			elif(item == 'Quantum Cloak'):
				Global.set_can_noclip(true)
	else:
		ExclMark.set_visible(false)
		PopUp.set_visible(false)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		if(anim_sprite.animation == "default"):
			is_active=true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_active=false

func _on_button_pressed():
	PopUp.set_visible(false)
	is_active = false

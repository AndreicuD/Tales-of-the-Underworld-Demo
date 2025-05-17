extends Node2D

@export var npc_id : String = "npc"
@export var font_size : int = 48

@export var particles : bool = false
@onready var part : GPUParticles2D = $GPUParticles2D

@export var button_text : String = "Nice"

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var ExclMark : Sprite2D = $"Exclamation Mark"
@onready var ExclMarkAnim : AnimationPlayer = $"Exclamation Mark/AnimationPlayer"

@onready var PopUp : CanvasLayer = $"PopUp"
@onready var PopUpText : Label = $"PopUp/Text"
@onready var down_button : Button = $"PopUp/Ok Button"

var is_active : bool

func _ready():
	if particles:
		$AnimatedSprite2D.play("important")
	else:
		$AnimatedSprite2D.play("default")
	part.set_visible(particles)
	PopUpText.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	PopUpText.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	PopUpText.add_theme_font_size_override("font_size", font_size)
	down_button.set_text(button_text)

func _process(_delta):
	if is_active:
		ExclMark.set_visible(true)
		ExclMarkAnim.play("Up-Down")
		if Input.is_action_just_pressed("Interact"):
			var text = Quest.get_npc_reaction(npc_id)
			PopUpText.set_text(text)
			Global.save_game()
			PopUp.set_visible(true)
	else:
		ExclMark.set_visible(false)
		PopUp.set_visible(false)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		is_active=true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_active=false

func _on_button_pressed():
	PopUp.set_visible(false)
	is_active = false

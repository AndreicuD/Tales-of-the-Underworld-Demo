extends Node2D

@export var quest : String

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var ExclMark : Sprite2D = $"Exclamation Mark"
@onready var ExclMarkAnim : AnimationPlayer = $"Exclamation Mark/AnimationPlayer"

var is_active : bool
func _ready():
	match quest:
		"find_money_1":
			$AnimatedSprite2D.play("small_money")
			$AnimationPlayer.play("bob")
		"find_money_2":
			$AnimatedSprite2D.play("big_money")
			$AnimationPlayer.play("bob")
		"find_child":
			$AnimatedSprite2D.play("child")
			$AnimationPlayer.play("RESET")

func _process(_delta):
	if is_active:
		if Quest.is_quest_started(quest):
			ExclMark.set_visible(true)
			ExclMarkAnim.play("Up-Down")
		if Input.is_action_just_pressed("Interact"):
			var to_delete = false
			match quest:
				"find_money_1":
					if Quest.is_quest_started("find_money_1"):
						to_delete = true
						Quest.money_found_1 = true
						get_tree().get_first_node_in_group("father").global_position = Vector2(-88.0, 8.0)
				"find_money_2":
					if Quest.is_quest_started("find_money_2"):
						to_delete = true
						Quest.money_found_2 = true
				"find_child":
					if Quest.is_quest_started("find_child"):
						to_delete = true
						Quest.child_found = true
			if to_delete:
				queue_free()
	else:
		ExclMark.set_visible(false)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
			is_active=true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_active=false

func _on_button_pressed():
	is_active = false

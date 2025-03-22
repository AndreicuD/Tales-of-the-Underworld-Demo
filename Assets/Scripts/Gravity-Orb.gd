extends Area2D

#active is true if player is in area
var active : bool = false
#disable bool to...disable the orb
var disabled : bool = false

@onready var cooldownTimer : Timer = $Timer
@onready var anim : AnimationPlayer = $"OrbSprite/AnimationPlayer"

func _process(_delta):
	if active and Input.is_action_just_pressed("Jump") and !disabled:
		anim.play("Disappear")
		disabled = true
		active=false
		Global.invert_gravity(true);
		$Particles.emitting = true
		cooldownTimer.start()

func _on_body_entered(body):
	if body.is_in_group("Player") and !disabled:
		active=true;

func _on_body_exited(body):
	if body.is_in_group("Player") and !disabled:
		active=false;

func _on_timer_timeout():
	disabled=false
	anim.play("default")

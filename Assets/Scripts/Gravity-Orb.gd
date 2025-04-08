extends Area2D

#active is true if player is in area
var active : bool = false
var player
#disable bool to...disable the orb
var disabled : bool = false

@onready var cooldownTimer : Timer = $Timer
@onready var anim : AnimationPlayer = $"OrbSprite/AnimationPlayer"

func _process(_delta):
	if active && !disabled:
		anim.play("Disappear")
		disabled = true
		active=false
		Global.can_change_gravity = true
		player.has_changed_gravity = false
		Global.gravity_cooldown.stop()
		$Particles.emitting = true
		cooldownTimer.start()

func _on_body_entered(body):
	if body.is_in_group("Player") and !disabled:
		player = body
		active=true;

func _on_body_exited(body):
	if body.is_in_group("Player") and !disabled:
		active=false;

func _on_timer_timeout():
	disabled=false
	anim.play("default")

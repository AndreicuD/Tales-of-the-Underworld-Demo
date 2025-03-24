extends RigidBody2D

# Custom gravity scale (if you want to adjust gravity for this specific object)
var gravity
@export var custom_gravity_scale : float = 0.5
@export var invert_gravity : bool = false
@export var time_change : bool = false
@export var time : float = 2

@onready var timer = $Timer
@onready var anim = $AnimationPlayer

func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * custom_gravity_scale * (-1 if invert_gravity else 1)
	timer.wait_time = time
	if time_change:
		timer.start()

func _physics_process(delta):
	# Get the default gravity from project settings
	if !time_change:
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * custom_gravity_scale * (-1 if invert_gravity else 1)
	else:
		if timer.time_left < 0.75:
			anim.play("shake")

	# Apply the gravity manually to the velocity
	linear_velocity.y += gravity * delta

func _on_timer_timeout():
	gravity *= -1

func _on_body_entered(body):
	if !body.is_in_group("Player"):
		$AudioStreamPlayer2D.play()

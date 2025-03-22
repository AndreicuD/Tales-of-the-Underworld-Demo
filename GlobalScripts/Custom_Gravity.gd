extends RigidBody2D

# Custom gravity scale (if you want to adjust gravity for this specific object)
@export var custom_gravity_scale : float = 0.5

func _physics_process(delta):
	# Get the default gravity from project settings
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * custom_gravity_scale

	# Apply the gravity manually to the velocity
	linear_velocity.y += gravity * delta

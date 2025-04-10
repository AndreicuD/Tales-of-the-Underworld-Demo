extends CharacterBody2D

var can_move : bool = true
var is_dead : bool = false

var can_push : bool = false
var pushing : bool = false
var box : RigidBody2D

var direction_x
var current_speed : float
@export var speed = 95.0
@export var push_speed = 45.0
@export var jump_power = 225.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var is_gravity_reversed : bool
var has_changed_gravity: bool = false

@onready var death_timer : Timer = $Death_Timer

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

@onready var box_ray : RayCast2D = $Box_Raycast
@onready var box_ray_down : RayCast2D = $Box_Raycast_Down

@onready var die_particles : GPUParticles2D = $Die_Particles
@onready var die_particle_material : ParticleProcessMaterial = die_particles.process_material
@onready var walk_particles : GPUParticles2D = $Ground_Particles
@onready var walk_particle_material : ParticleProcessMaterial = walk_particles.process_material
@onready var jump_particles : GPUParticles2D = $Jump_Particles
@onready var jump_particle_material : ParticleProcessMaterial = jump_particles.process_material

@onready var dead_audio = $Dead_Audio
@onready var gravity_audio = $Gravity_Audio
@onready var jump_audio = $Jump_Audio
@onready var walk_audio = $Walk_Audio
@onready var walk_audio_timer = $Walk_Audio_Timer

var has_key : bool = false

#verify if grounded even if gravity is reversed
func is_on_ground():
	if is_gravity_reversed and is_on_ceiling():
		return true
	if !is_gravity_reversed and is_on_floor():
		return true
	return false
func is_on_ceiling_custom():
	if is_gravity_reversed and is_on_floor():
		return true
	if !is_gravity_reversed and is_on_ceiling():
		return true
	return false

func set_particles_gravity(multiplier):
	var new_gravity = Vector3(0, 98 * multiplier, 0)
	walk_particle_material.gravity = new_gravity
	die_particle_material.gravity = new_gravity

func remove_danger_collision():
	self.collision_mask &= ~(1 << 3)
	self.collision_mask &= ~(1 << 1)
func add_danger_collision():
	self.collision_mask |= (1 << 3)
	self.collision_mask |= (1 << 1)

func remove_noclip_layer_collision():
	self.collision_mask &= ~(1 << 5)
func add_noclip_layer_collision():
	self.collision_mask |= (1 << 5)

func die():
	is_dead = true
	Global.play_transition("Death_Fade_In")
	remove_danger_collision()
	death_timer.start()
	can_move = false
	die_particles.emitting = true
	anim.play("Dead")
	dead_audio.play()

func _on_death_timer_timeout():
	Global.play_transition("Death_Fade_Out")
	add_danger_collision()
	Global.player_death()
	is_dead = false

func _on_transition_manager_animation_finished(anim_name):
	if(anim_name == "Death_Fade_Out"):
		can_move = true

func _physics_process(delta):
	if can_push && Input.is_action_pressed("Grab_Box"):
		pushing = true
		if box:
			box.is_pushed()
	else:
		pushing = false

	if pushing:
		current_speed = push_speed
	else:
		current_speed = speed

	if !death_timer.is_stopped():
		anim.play("Dead")
	if is_on_ground():
		if has_changed_gravity:  # Only reset when transitioning from air to ground
			has_changed_gravity = false
	else:
		walk_particles.emitting = false
		anim.play("Jumping")

	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	velocity.y = clamp(velocity.y, -300, 300)

	if Input.is_action_just_pressed("Jump") and is_on_ground() && can_move  && !pushing:
		velocity.y -= jump_power
		jump_audio.play()
		jump_particles.emitting = true
	elif Input.is_action_just_pressed("Jump") && !is_on_ground() && !has_changed_gravity && Global.can_change_gravity  && !pushing:
		Global.invert_gravity()
		gravity_audio.play()

	direction_x = Input.get_axis("Left", "Right")

	if direction_x && can_move:
		if direction_x<0:
			anim.set_scale(Vector2(-1, 1))
		elif direction_x>0:
			anim.set_scale(Vector2(1, 1))
		velocity.x = direction_x * current_speed
		if is_on_ground():
			anim.play("Running")
			walk_particles.emitting = true
	else:
		if is_on_ground():
			if death_timer.is_stopped():
				anim.play("Idle")
			walk_particles.emitting = false
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

	var collision_box_up_gravity = 0
	var collision_box_down_gravity = 0
	if box_ray.get_collider():
		collision_box_up_gravity = box_ray.get_collider().gravity
	if box_ray_down.get_collider():
		collision_box_down_gravity = box_ray_down.get_collider().gravity
	if !is_dead && ((box_ray.is_colliding() && is_on_ground() && collision_box_up_gravity == ProjectSettings.get_setting("physics/2d/default_gravity")) || (box_ray_down.is_colliding() && is_on_ceiling_custom() && collision_box_down_gravity == ProjectSettings.get_setting("physics/2d/default_gravity") * -1)):
		die()

	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		if body.is_in_group("Danger"):
			die()

func _on_walk_audio_timer_timeout():
	if walk_particles.emitting:
		walk_audio.play()

func _on_box_push_zone_body_entered(body):
	if body.can_be_pushed:
		can_push = true
		box = body

func _on_box_push_zone_body_exited(_body):
	can_push = false
	box = null

extends CharacterBody2D

var can_move = true
var is_dead = false

var direction_x
@export var speed = 95.0
@export var jump_power = 225.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var is_gravity_reversed : bool
var has_changed_gravity: bool = false

@onready var death_timer : Timer = $Death_Timer

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

@onready var box_ray : RayCast2D = $Box_Raycast

@onready var die_particles : GPUParticles2D = $Die_Particles
@onready var die_particle_material : ParticleProcessMaterial = die_particles.process_material
@onready var walk_particles : GPUParticles2D = $Ground_Particles
@onready var walk_particle_material : ParticleProcessMaterial = walk_particles.process_material
@onready var jump_particles : GPUParticles2D = $Jump_Particles
@onready var jump_particle_material : ParticleProcessMaterial = jump_particles.process_material

@onready var jump_audio = $Jump_Audio

@onready var walk_audio_timer = $Walk_Audio_Timer
@onready var walk_audio = $Walk_Audio

var has_key : bool = false

#verify if grounded even if gravity is reversed
func is_on_ground():
	if is_gravity_reversed and is_on_ceiling():
		return true
	if !is_gravity_reversed and is_on_floor():
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

func die():
	Global.play_transition("Death_Fade_In")
	remove_danger_collision()
	death_timer.start()
	can_move = false
	die_particles.emitting = true
	anim.play("Dead")

func _on_death_timer_timeout():
	Global.play_transition("Death_Fade_Out")
	add_danger_collision()
	Global.player_death()
func _on_transition_manager_animation_finished(anim_name):
	if(anim_name == "Death_Fade_Out"):
		can_move = true

func _physics_process(delta):
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

	if Input.is_action_just_pressed("Jump") and is_on_ground() && can_move:
		velocity.y -= jump_power
		jump_audio.play()
		jump_particles.emitting = true
	elif Input.is_action_just_pressed("Jump") and !is_on_ground() and !has_changed_gravity and Global.can_change_gravity:
		Global.invert_gravity()

	direction_x = Input.get_axis("Left", "Right")

	if direction_x && can_move:
		if direction_x<0:
			anim.set_scale(Vector2(-1, 1))
		elif direction_x>0:
			anim.set_scale(Vector2(1, 1))
		velocity.x = direction_x * speed
		if is_on_ground():
			anim.play("Running")
			walk_particles.emitting = true
	else:
		if is_on_ground():
			if death_timer.is_stopped():
				anim.play("Idle")
			walk_particles.emitting = false
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	if(box_ray.is_colliding() && is_on_ground()):
		die()

	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		if body.is_in_group("Danger"):
			die()

func _on_walk_audio_timer_timeout():
	if walk_particles.emitting:
		walk_audio.play()

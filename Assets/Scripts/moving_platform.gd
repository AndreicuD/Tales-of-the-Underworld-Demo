extends CharacterBody2D

@export_enum("1" ,"2", "3") var platform_size: int = 1
@onready var coll_1 = $"1"
@onready var coll_2 = $"2"
@onready var coll_3 = $"3"

func _ready():
	$AnimatedSprite2D.play("1")
	coll_1.disabled = false
	coll_2.disabled = true
	coll_3.disabled = true
	if platform_size == 1:
		$AnimatedSprite2D.play("2")
		coll_1.disabled = true
		coll_2.disabled = false
		coll_3.disabled = true
	elif platform_size == 2:
		$AnimatedSprite2D.play("3")
		coll_1.disabled = true
		coll_2.disabled = true
		coll_3.disabled = false

func _physics_process(_delta):
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		if body.is_in_group("Player"):
			print("Lovit")
			$AnimatedSprite2D/AnimationPlayer.play("default")

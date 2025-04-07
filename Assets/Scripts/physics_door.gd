extends StaticBody2D

@export var vertical : bool = false
@export_enum("Left/Up", "Right/Down") var open_direction : int = 0
var target_location : Vector2
var start_location : Vector2

func _ready():
	start_location = self.position
	target_location = start_location

func _physics_process(delta):
	self.position = self.position.lerp(target_location, delta * 4)

func open():
	if !vertical:
		target_location = start_location + Vector2((open_direction - 0.5) * 2 * 58, 0)
	else:
		target_location = start_location + Vector2(0, (open_direction - 0.5) * 2 * 58)

func close():
	target_location = start_location

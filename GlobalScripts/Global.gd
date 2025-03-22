extends Node

var HEALTH = 100
var MAX_HEALTH = 100
var is_player_dead = false

var gravity_cooldown : Timer
var can_change_gravity : bool = false

var spawn_point = Vector2(0,0)
var spawn_point_gravity : String = 'down'

var default_max_health = 100
var default_spawn_point = Vector2(0,0)
var default_spawn_point_gravity : String = 'down'

#----------------------------------------------------------

var current_level : String
var has_save_file : bool = false

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	gravity_cooldown = Timer.new()
	gravity_cooldown.wait_time = 1
	gravity_cooldown.one_shot = true
	add_child(gravity_cooldown)
	#load_game()
	pass

func _physics_process(_delta):
	#reset player if health is below 0
	if(HEALTH<=0):
		player_death()

func play_transition(string : String):
	$"/root/SceneManager/TransitionManager".play_transition(string)
func color_manager_play_transition(string : String):
	$"/root/SceneManager/ColorManager".play_transition(string)

#----------------------------------------------------------

#https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
#look at this if you have problems
func save_game():
	var save_game_file = FileAccess.open("res://savegame.save", FileAccess.WRITE)

	var max_health_dic = {
		"what_is_saved" : "max_health",
		"amount" : MAX_HEALTH
	}

	var spawn_point_dic = {
		"what_is_saved" : "spawn_point",
		"position" : var_to_str(get_spawn_point()),
		"gravity" : get_spawn_point_gravity(),
	}

	var max_health_info = JSON.stringify(max_health_dic)
	save_game_file.store_line(max_health_info)
	var spawn_point_info = JSON.stringify(spawn_point_dic)
	save_game_file.store_line(spawn_point_info)

func load_game():
	if not FileAccess.file_exists("res://savegame.save"):
		return #error, file wasn't found

	var save_game_file = FileAccess.open("res://savegame.save", FileAccess.READ)
	has_save_file = true

	#citeste fiecare linie
	while save_game_file.get_position() < save_game_file.get_length():
		var json_string = save_game_file.get_line()
		var json = JSON.new()
		# Creates the helper class to interact with JSON

		var parse_result = json.parse(json_string)
		#we parse and verify if it's ok
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		#read that line
		var node_data = json.get_data()

		#verify what it is
		match node_data["what_is_saved"]:
			"spawn_point":
				set_spawn_point(str_to_var(node_data["position"]), node_data["gravity"])
			"max_health":
				set_max_health(float(node_data["amount"]))

func delete_save():
	var dir = DirAccess.open("res://")
	if FileAccess.file_exists("res://savegame.save"):
		dir.remove("res://savegame.save")
	MAX_HEALTH = default_max_health
	spawn_point = default_spawn_point
	spawn_point_gravity = default_spawn_point_gravity
	has_save_file = false

#----------------------------------------------------------

#in level
func reset_player_position_and_health():
	var Player = get_tree().get_first_node_in_group("Player")
	Player.position = default_spawn_point
	force_gravity_down()
	HEALTH = MAX_HEALTH

func reset_player_to_checkpoint():
	var Player = get_tree().get_first_node_in_group("Player")
	Player.position = get_spawn_point()
	var new_gravity = get_spawn_point_gravity()
	if(new_gravity == 'down'):
		force_gravity_down()
	else:
		force_gravity_up()
	HEALTH = MAX_HEALTH

func player_death():
	reset_player_to_checkpoint()

func death_timer_timeout():
	TransitionManager.play_transition("Death_Fade_Out")
	#is_player_dead = false
	reset_player_position_and_health()

#----------------------------------------------------------

func set_spawn_point(new_point, new_gravity):
	spawn_point = new_point
	spawn_point_gravity = new_gravity
	save_game()

func get_spawn_point():
	return spawn_point
func get_spawn_point_gravity():
	return spawn_point_gravity

#----------------------------------------------------------

func set_health(health):
	HEALTH = health

func set_max_health(health):
	MAX_HEALTH = health

func get_health():
	return HEALTH

func get_max_health():
	return MAX_HEALTH

func heal_health(healAmount):
	HEALTH += healAmount

func take_damage(damage):
	HEALTH -= damage

func force_gravity_down():
	var new_gravity = abs(ProjectSettings.get_setting("physics/2d/default_gravity"))
	ProjectSettings.set_setting("physics/2d/default_gravity", new_gravity)

	var Player = get_tree().get_first_node_in_group("Player")
	Player.is_gravity_reversed = false
	color_manager_play_transition("InvertColor_FadeOut")
	Player.jump_power = abs(Player.jump_power)
	Player.set_particles_gravity(1)
	Player.set_scale(Vector2(Player.scale.x, abs(Player.scale.y)))
	Player.has_changed_gravity = false

func force_gravity_up():
	var new_gravity = -abs(ProjectSettings.get_setting("physics/2d/default_gravity"))
	ProjectSettings.set_setting("physics/2d/default_gravity", new_gravity)

	var Player = get_tree().get_first_node_in_group("Player")
	Player.is_gravity_reversed = true
	color_manager_play_transition("InvertColor_FadeIn")
	Player.jump_power = -abs(Player.jump_power)
	Player.set_particles_gravity(-1)
	Player.set_scale(Vector2(Player.scale.x, -abs(Player.scale.y)))
	Player.has_changed_gravity = false

func invert_gravity():
	if gravity_cooldown.is_stopped():
		gravity_cooldown.start()
		print("Gravity Changed")

		var new_gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * -1
		ProjectSettings.set_setting("physics/2d/default_gravity", new_gravity)

		var Player = get_tree().get_first_node_in_group("Player")
		Player.is_gravity_reversed = !Player.is_gravity_reversed
		Player.jump_power *= -1
		if Player.is_gravity_reversed:
			color_manager_play_transition("InvertColor_FadeIn")
		else:
			color_manager_play_transition("InvertColor_FadeOut")
		Player.set_particles_gravity((-1 if Player.is_gravity_reversed else 1))
		Player.set_scale(Vector2(Player.scale.x, abs(Player.scale.y) * (-1 if Player.is_gravity_reversed else 1)))
		Player.has_changed_gravity = true

#----------------------------------------------------------

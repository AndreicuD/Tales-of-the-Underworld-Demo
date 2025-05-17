extends Node

#used by other scripts (like the box script)
var PLAYER : CharacterBody2D

var HEALTH = 100
var MAX_HEALTH = 100

#0 - Menu, 1 -underground
var WORLD : int
@onready var music_player : AudioStreamPlayer = get_tree().get_first_node_in_group("Music_Player")

var CURRENCY : int = 0
var CURRENT_LEVEL_CURRENCY : int = 0
var is_player_dead = false

var gravity_cooldown : Timer
var can_change_gravity : bool = false
var can_noclip : bool = false

var spawn_point = Vector2(0,0)
var spawn_point_gravity : String = 'down'

var default_max_health = 100
var default_spawn_point = Vector2(0,0)
var default_spawn_point_gravity : String = 'down'

@onready var world_environment : Environment = get_tree().get_first_node_in_group("world_environment").environment
@onready var color_shader : Material = get_tree().get_first_node_in_group("color+contrast_shader").material
@onready var vignette_shader : Material = get_tree().get_first_node_in_group("vignette_shader").material
var master_vol : float
var music_vol : float
var sfx_vol : float
var fullscreen : bool
var bloom : bool
var invert_color : bool
var contrast : float
var brightness : float
var vignette : float

#----------------------------------------------------------

var levels_visited : Array[String]
var collectibles_got : Array[String]
var current_level : String = "Start"
var max_level : String = "Menu"
var has_save_file : bool = false
var gravity_when_save : bool = false
var noclip_when_save : bool = false

func _ready():
	Quest.mother_spoken_to = false
	Quest.husband_found = false
	Quest.money_found_1 = false
	Quest.child_found = false
	Quest.selfish_spoken_to = false
	Quest.money_found_2 = false
	PLAYER = get_tree().get_first_node_in_group("Player")
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	gravity_cooldown = Timer.new()
	gravity_cooldown.wait_time = 1
	gravity_cooldown.one_shot = true
	add_child(gravity_cooldown)
	load_game()
	load_settings()
	#load_scene("Tutorial")
	pass

func _physics_process(_delta):
	print(Quest.key_pieces)
	#reset player if health is below 0
	if !Global.levels_visited.is_empty():
		max_level = levels_visited.back()
	else:
		max_level = "Menu"
	if Input.is_action_just_pressed("Reset"):
		if current_level != 'Menu' && current_level != 'Start':
			reset_player_to_checkpoint()
		else:
			var Player = get_tree().get_first_node_in_group("Player")
			Player.position = Vector2(0, 0)
			force_gravity_down()

	if Input.is_action_just_pressed("Pause"):
		load_scene("Menu")
	if(HEALTH<=0):
		player_death()

func load_scene(wanted_scene : String, player_to_spawn_point : bool = false):
	get_tree().get_first_node_in_group("scene_manager").change_level(wanted_scene, player_to_spawn_point)
func play_transition(string : String):
	$"/root/SceneManager/TransitionManager".play_transition(string)
func color_manager_play_transition(string : String):
	if invert_color:
		$"/root/SceneManager/ColorManager".play_transition(string)

func change_music(world : int):
	music_player.get_stream_playback().switch_to_clip(world)

#----------------------------------------------------------
#GAME SETTINGS
func toggle_bloom(value : bool):
	bloom = value
	world_environment.glow_enabled = value

func toggle_invert_color(value : bool):
	if value == false:
		color_manager_play_transition("InvertColor_FadeOut")
	else:
		invert_color = true
		color_manager_play_transition("InvertColor_FadeIn")
	invert_color = value
	#get_tree().get_first_node_in_group("invert_color_canvas").visible = value

func change_contrast(value : float):
	contrast = value
	color_shader.set_shader_parameter("contrast", value)

func change_brightness(value : float):
	brightness = value
	color_shader.set_shader_parameter("brightness", value)

func change_vignette(value : float):
	vignette = value
	vignette_shader.set_shader_parameter("MainAlpha", value)

func toggle_fullscreen(value : bool):
	fullscreen = value
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

#----------------------------------------------------------

func reset_game():
	CURRENCY = 0
	CURRENT_LEVEL_CURRENCY = 0

	MAX_HEALTH = default_max_health
	HEALTH = default_max_health

	levels_visited = []
	collectibles_got = []

	spawn_point = default_spawn_point
	spawn_point_gravity = default_spawn_point_gravity

#https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
#look at this if you have problems
func save_settings():
	var save_settings_file = FileAccess.open("res://settings.file", FileAccess.WRITE)

	var volume_dic = {
		"what_is_saved" : "volumes",
		"master_vol" : master_vol,
		"music_vol" : music_vol,
		"sfx_vol" : sfx_vol
	}

	var video_settings_dic = {
		"what_is_saved" : "video_settings",
		"bloom" : bloom,
		"invert_color" : invert_color,
		"fullscreen" : fullscreen,
		"contrast" : contrast,
		"brightness" : brightness,
		"vignette" : vignette
	}

	var volume_info = JSON.stringify(volume_dic)
	save_settings_file.store_line(volume_info)
	var video_info = JSON.stringify(video_settings_dic)
	save_settings_file.store_line(video_info)

	print("Settings Saved")

func load_settings():
	if not FileAccess.file_exists("res://settings.file"):
		return #error, file wasn't found

	var save_settings_file = FileAccess.open("res://settings.file", FileAccess.READ)

	#citeste fiecare linie
	while save_settings_file.get_position() < save_settings_file.get_length():
		var json_string = save_settings_file.get_line()
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
			"volumes":
				master_vol = node_data["master_vol"]
				music_vol = node_data["music_vol"]
				sfx_vol = node_data["sfx_vol"]
			"video_settings":
				bloom = node_data["bloom"]
				toggle_bloom(bloom)
				invert_color = node_data["invert_color"]
				toggle_invert_color(invert_color)
				color_manager_play_transition("InvertColor_FadeOut")
				fullscreen = node_data["fullscreen"]
				toggle_fullscreen(fullscreen)
				contrast = node_data["contrast"]
				change_contrast(contrast)
				brightness = node_data["brightness"]
				change_brightness(brightness)
				vignette = node_data["vignette"]
				change_vignette(vignette)

		print("Settings Loaded")

func save_game():
	var save_game_file = FileAccess.open("res://savegame.save", FileAccess.WRITE)

	var currency_dic = {
		"what_is_saved" : "currency",
		"amount" : CURRENCY
	}
	
	var quest_dic = {
		"what_is_saved" : "quest",
		"quests" : Quest.quests,
		"key_pieces" : Quest.key_pieces,
		"mother_spoken_to" : Quest.mother_spoken_to,
		"husband_found" : Quest.husband_found,
		"money_found_1" : Quest.money_found_1,
		"child_found" : Quest.child_found,
		"selfish_spoken_to" : Quest.selfish_spoken_to,
		"money_found_2" : Quest.money_found_2,
	}
	
	var level_dic = {
		"what_is_saved" : "level_info",
		"levels" : levels_visited,
		"collectibles" : collectibles_got
	}

	var spawn_point_dic = {
		"what_is_saved" : "spawn_point",
		"position" : var_to_str(get_spawn_point()),
		"gravity" : get_spawn_point_gravity(),
		"gravity_when_saved" : gravity_when_save,
		"noclip_when_saved" : noclip_when_save
	}

	var currency_info = JSON.stringify(currency_dic)
	save_game_file.store_line(currency_info)
	var level_info = JSON.stringify(level_dic)
	save_game_file.store_line(level_info)
	var quest_info = JSON.stringify(quest_dic)
	save_game_file.store_line(quest_info)
	var spawn_point_info = JSON.stringify(spawn_point_dic)
	save_game_file.store_line(spawn_point_info)

	print("Game Saved")

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
			"currency":
				set_currency(node_data['amount'])
				CURRENT_LEVEL_CURRENCY = 0
			"level_info":
				for level in node_data['levels']:
					levels_visited.push_back(level)
				for collectible in node_data['collectibles']:
					collectibles_got.push_back(collectible)
			"quest":
				Quest.mother_spoken_to = node_data["mother_spoken_to"]
				Quest.husband_found = node_data["husband_found"]
				Quest.money_found_1 = node_data["money_found_1"]
				Quest.child_found = node_data["child_found"]
				Quest.selfish_spoken_to = node_data["selfish_spoken_to"]
				Quest.money_found_2 = node_data["money_found_2"]

	print("Game Loaded")

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

#----------------------------------------------------------

func set_spawn_point(new_point, new_gravity):
	if(current_level != "Menu"):
		spawn_point = new_point
		spawn_point_gravity = new_gravity
		print("Spawn Point Set - ", spawn_point)
		save_game()

func get_spawn_point():
	return spawn_point
func get_spawn_point_gravity():
	return spawn_point_gravity

#----------------------------------------------------------

func set_can_noclip(value : bool):
	var Player = get_tree().get_first_node_in_group("Player")
	can_noclip = value
	if(value):
		Player.remove_noclip_layer_collision()
	else:
		Player.add_noclip_layer_collision()

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

func get_currency():
	return CURRENCY + CURRENT_LEVEL_CURRENCY
func set_currency(amount):
	CURRENCY = amount
func load_currency():
	CURRENCY += CURRENT_LEVEL_CURRENCY
	CURRENT_LEVEL_CURRENCY = 0

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

func force_gravity_invert():
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

func invert_gravity(force_invert : bool = false):
	if !force_invert && gravity_cooldown.is_stopped():
		gravity_cooldown.start()
		force_gravity_invert()
	else:
		force_gravity_invert()

#----------------------------------------------------------

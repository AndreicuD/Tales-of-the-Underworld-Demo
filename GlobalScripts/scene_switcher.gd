extends Node

var current_level
var current_level_name
var is_loading_level : bool = false
var change_location : bool = false

var next_level = null
var next_level_name : String

func _ready():
	current_level = get_tree().get_first_node_in_group("Level")

func change_level(wanted_level_name : String , should_change_spawn_location : bool = false):
	change_location = should_change_spawn_location
	if is_loading_level:
		return
	is_loading_level=true

	next_level = load("res://Levels/" + wanted_level_name + ".tscn").instantiate()
	next_level_name = wanted_level_name
	Global.play_transition("Fade_In")

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Fade_In":
			if(current_level):
				current_level.queue_free()

			current_level = next_level
			add_child(current_level)

			Global.load_currency()
			if !change_location && next_level_name != "Menu":
				Global.set_spawn_point(Global.default_spawn_point, Global.default_spawn_point_gravity)

			current_level_name = next_level_name
			Global.current_level = current_level_name

			if (current_level_name != "Menu"):
				if Global.levels_visited.is_empty():
					Global.levels_visited.push_back(current_level_name)
				else:
					var level_already_visited : bool = false
					for i in Global.levels_visited:
						if i == current_level_name:
							level_already_visited = true
					if !level_already_visited:
						Global.levels_visited.push_back(current_level_name)
						Global.save_game()

			if change_location:
				Global.reset_player_to_checkpoint()
			else:
				Global.reset_player_position_and_health()

			Global.play_transition("Fade_Out")
		"Fade_Out":
			is_loading_level=false
			next_level=null

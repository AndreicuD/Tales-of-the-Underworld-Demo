extends Node

# Signals
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal key_piece_obtained(piece_id: String)

var mother_spoken_to : bool = false
var husband_found : bool = false
var money_found_1 : bool = false
var child_found : bool = false

var selfish_spoken_to : bool = false
var money_found_2 : bool = false

# Quest data
var quests = {
	"find_husband": {
		"title" : "Find my husband!",
		"completed" : false,
		"started" : false,
		"rewards": {
			"money": 0,
			"key_piece": "",  # No key piece reward for this quest
		}
	},
	"find_money_1": {
		"title" : "Where is my fortune?!",
		"completed" : false,
		"started" : false,
		"rewards": {
			"money": 0,
			"key_piece": "",  # No key piece reward for this quest
		}
	},
	"find_child": {
		"title": "Find my lost child!",
		"completed": false,
		"started" : false,
		"rewards": {
			"money": 0,
			"key_piece": "",  # No key piece reward for this quest
		}
	},
	"find_money_2": {
		"title" : "Where is my fortune?!",
		"completed" : false,
		"started" : false,
		"rewards": {
			"money": 0,
			"key_piece": "",  # No key piece reward for this quest
		}
	},
}

# Key pieces data
var key_pieces = {
	"key_piece_1": {
		"obtained": false,
	},
	"key_piece_2": {
		"obtained": false,
	},
	"key_piece_3": {
		"obtained": false,
	},
	"key_piece_4": {
		"obtained": false,
	},
}

func _process(_delta):
	if has_key_piece("key_piece_1") && has_key_piece("key_piece_2") && has_key_piece("key_piece_3"):
		get_tree().get_first_node_in_group("boschete").global_position = Vector2(200, -8)

# Get information about an NPC's reaction based on quest status
func get_npc_reaction(npc_id: String) -> String:
	match npc_id:
		"selfish":
			if money_found_2 && money_found_1 && selfish_spoken_to:
				complete_quest("find_money_2")
				obtain_key_piece("key_piece_2")
				return "Thank you for your help, muahaha. Here, I guess you can have my Core Fragment"
			if money_found_1 && selfish_spoken_to:
				start_quest("find_money_2")
				return "Hmm, you have some money right now, but it's not enough! Find my stash north of here!"
			selfish_spoken_to = true
			return "I have one of those Core Fragments, but everything comes for a price! Come to me later, when you gather some money."
		"father":
			if money_found_1 && mother_spoken_to:
				complete_quest("find_money_1")
				return "Thank you for finding my money. You can keep some of it."
			if mother_spoken_to:
				husband_found = true
				start_quest("find_money_1")
				return "I hate this place, but the only way to leave is to get all 4 Core Fragments! Help me find my fortune please, I've lost it in this mess."
			return "Please talk to my wife first, she's gonna tell you some more info."
		"mother":
			if child_found && husband_found:
				obtain_key_piece("key_piece_1")
				return "It feels good to have my child back. Here, have this Core Fragment."
			if husband_found:
				complete_quest("find_husband")
				start_quest("find_child")
				get_tree().get_first_node_in_group("child").global_position = Vector2(1360, -488)
				return "How could he say that! Now my kid ran from home. Please help me find him"
			mother_spoken_to = true
			start_quest("find_husband")
			return "I really like it here but my husband is missing! Please hurry up and help me find him!"
		"boschete":
			Global.load_scene("end_game")
			return "Ha, you found them! So the legend is true...."
	return "Hello there!"

# Quest Functions
func start_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		push_error("Quest ID not found: " + quest_id)
		return false
		
	if quests[quest_id]["completed"]:
		print("Quest already completed: " + quest_id)
		return false
	
	emit_signal("quest_started", quest_id)
	quests[quest_id]['started'] = true
	print("Started quest: " + quests[quest_id]["title"])
	return true
	
func complete_quest(quest_id: String) -> bool:
	if not quests.has(quest_id):
		push_error("Quest ID not found: " + quest_id)
		return false
	
	var quest = quests[quest_id]
	if quest["completed"]:
		print("Quest already completed: " + quest_id)
		return false
	
	# Mark as completed
	quest["completed"] = true
	
	# Award rewards
	if quest["rewards"]["money"] > 0:
		Global.add_currency(quest["rewards"]["money"])
	
	if quest["rewards"]["key_piece"] != "":
		obtain_key_piece(quest["rewards"]["key_piece"])
	
	emit_signal("quest_completed", quest_id)
	print("Completed quest: " + quest["title"])
	return true

func is_quest_completed(quest_id: String) -> bool:
	if not quests.has(quest_id):
		push_error("Quest ID not found: " + quest_id)
		return false
	
	return quests[quest_id]["completed"]

func is_quest_started(quest_id: String) -> bool:
	if not quests.has(quest_id):
		push_error("Quest ID not found: " + quest_id)
		return false
	
	return quests[quest_id]["started"]

# Key Piece Functions
func obtain_key_piece(piece_id: String) -> bool:
	if not key_pieces.has(piece_id):
		push_error("Key piece ID not found: " + piece_id)
		return false
	
	if key_pieces[piece_id]["obtained"]:
		print("Key piece already obtained: " + piece_id)
		return false
	
	key_pieces[piece_id]["obtained"] = true
	emit_signal("key_piece_obtained", piece_id)
	#print("Obtained key piece: " + key_pieces[piece_id]["name"])
	
	# Check if all pieces collected
	check_game_completion()
	
	return true

func has_key_piece(piece_id: String) -> bool:
	if not key_pieces.has(piece_id):
		push_error("Key piece ID not found: " + piece_id)
		return false
	
	return key_pieces[piece_id]["obtained"]

func get_all_key_pieces() -> Array:
	var obtained_pieces = []
	for piece_id in key_pieces:
		if key_pieces[piece_id]["obtained"]:
			obtained_pieces.append(piece_id)
	return obtained_pieces

# Game completion check
func check_game_completion() -> bool:
	for piece_id in key_pieces:
		if not key_pieces[piece_id]["obtained"]:
			return false
	
	# All key pieces obtained, game completed!
	Global.GAME_COMPLETED = true
	print("All key pieces obtained! Game completed!")
	return true

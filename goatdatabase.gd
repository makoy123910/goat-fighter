extends Node

# ========================================
# DATABASE DATA
# ========================================

var goat_types = {
	"GoatType1": {
		"name": "Goat Type 1",
		"portrait": preload("res://GoatFighter/Goats/Goat1.png"),
		"hp": 3,
		"rps_set_1": ["rock", "rock", "paper"],
		"rps_set_2": [],
		"rps_set_3": []
	},
	"GoatType2": {
		"name": "Goat Type 2",
		"portrait": preload("res://GoatFighter/Goats/Goat2.png"),
		"hp": 4,
		"rps_set_1": ["scissors", "scissors", "rock"],
		"rps_set_2": [],
		"rps_set_3": []
	},
	"GoatType3": {
		"name": "Goat Type 3",
		"portrait": preload("res://GoatFighter/Goats/Goat3.png"),
		"hp": 3,
		"rps_set_1": ["paper", "paper", "scissors"],
		"rps_set_2": [],
		"rps_set_3": []
	},
	"GoatType4": {
		"name": "Goat Type 4",
		"portrait": preload("res://GoatFighter/Goats/Goat4.png"),
		"hp": 3,
		"rps_set_1": ["rock", "scissors", "paper"],
		"rps_set_2": [],
		"rps_set_3": []
	},
	"GoatType5": {
		"name": "Goat Type 5",
		"portrait": preload("res://GoatFighter/Goats/Goat5.png"),
		"hp": 3,
		"rps_set_1": ["paper", "scissors", "scissors"],
		"rps_set_2": [],
		"rps_set_3": []
	},
	"GoatType6": {
		"name": "Goat Type 6",
		"portrait": preload("res://GoatFighter/Goats/Goat6.png"),
		"hp": 3,
		"rps_set_1": ["rock", "paper", "paper"],
		"rps_set_2": [],
		"rps_set_3": []
	},
	"GoatType7": {
		"name": "Goat Type 7",
		"portrait": preload("res://GoatFighter/Goats/Goat7.png"),
		"hp": 3,
		"rps_set_1": ["scissors", "rock", "rock"],
		"rps_set_2": [],
		"rps_set_3": []
	}
}


func _ready() -> void:
	randomize_rps_sets()


func randomize_rps_sets() -> void:
	var choices = ["rock", "paper", "scissors"]

	for goat_type in goat_types:
		goat_types[goat_type]["rps_set_2"] = [
			choices.pick_random(),
			choices.pick_random(),
			choices.pick_random()
		]

		goat_types[goat_type]["rps_set_3"] = [
			choices.pick_random(),
			choices.pick_random(),
			choices.pick_random()
		]


# ========================================
# RPS EVALUATION ENGINE
# ========================================

enum Result { WIN, LOSE, DRAW }

## Evaluates move_a vs move_b from move_a's perspective.
## Returns Result.WIN, Result.LOSE, or Result.DRAW.
func evaluate_matchup(move_a: String, move_b: String) -> Result:
	move_a = move_a.to_lower()
	move_b = move_b.to_lower()

	# 1. Identical move or Anti vs Anti / Null vs Null -> DRAW (no damage)
	if move_a == move_b:
		return Result.DRAW

	# 2. ANTI Interactions
	# If move_a is Anti, it beats EVERYTHING except another Anti
	if move_a == "anti":
		return Result.WIN
	# If move_b is Anti, move_a loses
	if move_b == "anti":
		return Result.LOSE

	# 3. NULL Interactions
	# If move_a is Null, it loses to EVERYTHING except another Null
	if move_a == "null":
		return Result.LOSE
	# If move_b is Null, move_a wins
	if move_b == "null":
		return Result.WIN

	# 4. Standard RPS Triangle
	match move_a:
		"rock":
			return Result.WIN if move_b == "scissors" else Result.LOSE
		"paper":
			return Result.WIN if move_b == "rock" else Result.LOSE
		"scissors":
			return Result.WIN if move_b == "paper" else Result.LOSE

	print("Warning: Unknown RPS comparison: ", move_a, " vs ", move_b)
	return Result.DRAW

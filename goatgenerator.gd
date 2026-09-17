extends Node

const GOATS_PER_DAY := 5

var current_goats: Array = []


func _ready() -> void:
	randomize()


func generate_goats() -> void:
	current_goats.clear()

	for i in range(GOATS_PER_DAY):
		var goat := generate_goat(i)
		current_goats.append(goat)

	print("================================")
	print("GENERATED GOATS: ", current_goats.size())
	print("================================")

	for goat in current_goats:
		print(
			goat["name"],
			" | ",
			goat["quality"],
			" | ",
			goat["set_1"],
			" | ",
			goat["set_2"]
		)


func generate_goat(id: int) -> Dictionary:
	var goat_keys = GoatDatabase.goat_types.keys()
	var random_type = goat_keys.pick_random()
	var base_goat: Dictionary = GoatDatabase.goat_types[random_type]

	var quality := get_random_quality()

	var set_1: Array = base_goat["rps_set_1"].duplicate()

	# Start Set 2 with normal RPS moves.
	var set_2: Array = generate_normal_rps_set()

	# Apply quality-specific Null / Anti rules.
	apply_quality_rps(set_1, set_2, quality)

	# --------------------------------
	# SET 3
	# TEMPORARY: Random RPS values for testing.
	# Later, Set 3 will start empty and be filled
	# by the player using RPS fragments.
	# --------------------------------
	var set_3: Array = generate_normal_rps_set()

	var goat := {
		"id": id,
		"name": base_goat["name"],
		"type": random_type,
		"quality": quality,
		"portrait": base_goat["portrait"],
		"hp": base_goat["hp"],

		"set_1": set_1,
		"set_2": set_2,

		# Player customization starts empty.
		"set_3": set_3
	}

	return goat


func get_random_quality() -> String:
	var qualities = [
		"poor",
		"common",
		"rare",
		"unique"
	]

	return qualities.pick_random()


func generate_normal_rps_set() -> Array:
	var choices = [
		"rock",
		"paper",
		"scissors"
	]

	return [
		choices.pick_random(),
		choices.pick_random(),
		choices.pick_random()
	]


func apply_quality_rps(
	set_1: Array,
	set_2: Array,
	quality: String
) -> void:

	var all_slots: Array = []

	for i in range(set_1.size()):
		all_slots.append({
			"set": set_1,
			"index": i
		})

	for i in range(set_2.size()):
		all_slots.append({
			"set": set_2,
			"index": i
		})


	# --------------------------------
	# POOR
	# 3–4 NULL
	# --------------------------------
	if quality == "poor":
		var null_count := randi_range(3, 4)

		all_slots.shuffle()

		for i in range(null_count):
			all_slots[i]["set"][all_slots[i]["index"]] = "null"


	# --------------------------------
	# COMMON
	# 1–2 NULL
	# --------------------------------
	elif quality == "common":
		var null_count := randi_range(1, 2)

		all_slots.shuffle()

		for i in range(null_count):
			all_slots[i]["set"][all_slots[i]["index"]] = "null"


	# --------------------------------
	# RARE
	# 0–1 NULL
	# --------------------------------
	elif quality == "rare":
		var null_count := randi_range(0, 1)

		all_slots.shuffle()

		for i in range(null_count):
			all_slots[i]["set"][all_slots[i]["index"]] = "null"


	# --------------------------------
	# UNIQUE
	# 1–2 ANTI
	# 0 NULL
	# --------------------------------
	elif quality == "unique":
		var anti_count := randi_range(1, 2)

		all_slots.shuffle()

		for i in range(anti_count):
			all_slots[i]["set"][all_slots[i]["index"]] = "anti"


func get_goat(index: int) -> Dictionary:
	if index < 0 or index >= current_goats.size():
		return {}

	return current_goats[index]


func get_all_goats() -> Array:
	return current_goats


func has_goats() -> bool:
	return not current_goats.is_empty()

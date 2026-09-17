extends Control

const GOAT_COUNT := 5

var current_goat_index := 0
var goats: Array = []


# ========================================
# UI REFERENCES
# ========================================

@onready var portrait: TextureRect = $Background/Portrait_Background/Goat_Portrait
@onready var portrait_background: TextureRect = $Background/Portrait_Background
@onready var hp_label: Label = $Background/HP/HPLabel


# ========================================
# BUTTONS
# ========================================

@onready var reject_button: Button = $Background/ButtonsRow/RejectImg/RejectButton
@onready var match_button: Button = $Background/ButtonsRow/MatchImg/MatchButton


# ========================================
# RPS CARDS
# ========================================

# SET 1
@onready var set1_cards = [
	$Background/VBoxContainer/HBoxContainer1/Set1/HBoxContainer/RPS1,
	$Background/VBoxContainer/HBoxContainer1/Set1/HBoxContainer/RPS2,
	$Background/VBoxContainer/HBoxContainer1/Set1/HBoxContainer/RPS3
]


# SET 2
@onready var set2_cards = [
	$Background/VBoxContainer/HBoxContainer2/Set2/HBoxContainer/RPS1,
	$Background/VBoxContainer/HBoxContainer2/Set2/HBoxContainer/RPS2,
	$Background/VBoxContainer/HBoxContainer2/Set2/HBoxContainer/RPS3
]


# SET 3
@onready var set3_cards = [
	$Background/VBoxContainer/HBoxContainer3/Set3/HBoxContainer/RPS1,
	$Background/VBoxContainer/HBoxContainer3/Set3/HBoxContainer/RPS2,
	$Background/VBoxContainer/HBoxContainer3/Set3/HBoxContainer/RPS3
]


# ========================================
# RPS TEXTURES
# ========================================

var rock_texture = preload(
	"res://GoatFighter/RPS/Rock.png"
)

var paper_texture = preload(
	"res://GoatFighter/RPS/Paper.png"
)

var scissors_texture = preload(
	"res://GoatFighter/RPS/Scissors.png"
)

var anti_texture = preload(
	"res://GoatFighter/RPS/Anti.png"
)

var null_texture = preload(
	"res://GoatFighter/RPS/Null.png"
)


# ========================================
# QUALITY BACKGROUNDS
# ========================================

var poor_background = preload(
	"res://GoatFighter/Portrait_BG/graybg1.png"
)

var common_background = preload(
	"res://GoatFighter/Portrait_BG/greenbg1.png"
)

var rare_background = preload(
	"res://GoatFighter/Portrait_BG/bluebg1.png"
)

var unique_background = preload(
	"res://GoatFighter/Portrait_BG/purplebg1.png"
)


# ========================================
# READY
# ========================================

func _ready() -> void:

	# --------------------------------
	# GENERATE GOATS
	# --------------------------------

	GoatGenerator.generate_goats()

	goats = GoatGenerator.get_all_goats()

	if goats.is_empty():
		print("No goats were generated.")
		return


	# --------------------------------
	# START WITH FIRST GOAT
	# --------------------------------

	current_goat_index = 0

	display_goat(
		goats[current_goat_index]
	)


	# --------------------------------
	# BUTTON CONNECTIONS
	# --------------------------------

	reject_button.pressed.connect(
		_on_reject_pressed
	)

	match_button.pressed.connect(
		_on_match_pressed
	)


# ========================================
# DISPLAY GOAT
# ========================================

func display_goat(goat: Dictionary) -> void:

	# --------------------------------
	# PORTRAIT
	# --------------------------------

	portrait.texture = goat["portrait"]


	# --------------------------------
	# QUALITY BACKGROUND
	# --------------------------------

	set_quality_background(
		goat["quality"]
	)


	# --------------------------------
	# HP
	# --------------------------------

	hp_label.text = "x" + str(
		goat["hp"]
	)


	# --------------------------------
	# RPS SET 1
	# --------------------------------

	update_rps_set(
		set1_cards,
		goat["set_1"]
	)


	# --------------------------------
	# RPS SET 2
	# --------------------------------

	update_rps_set(
		set2_cards,
		goat["set_2"]
	)


	# --------------------------------
	# RPS SET 3
	#
	# TEMPORARY:
	# Set 3 is randomly generated
	# for testing.
	#
	# Later this will be controlled
	# by the player using RPS fragments.
	# --------------------------------

	update_rps_set(
		set3_cards,
		goat["set_3"]
	)


# ========================================
# UPDATE RPS SET
# ========================================

func update_rps_set(
	cards: Array,
	rps_set: Array
) -> void:

	for i in range(cards.size()):

		if i >= rps_set.size():
			continue

		set_rps_card(
			cards[i],
			rps_set[i]
		)


# ========================================
# SET RPS CARD TEXTURE
# ========================================

func set_rps_card(
	card: TextureRect,
	rps: String
) -> void:

	match rps:

		"rock":
			card.texture = rock_texture

		"paper":
			card.texture = paper_texture

		"scissors":
			card.texture = scissors_texture

		"null":
			card.texture = null_texture

		"anti":
			card.texture = anti_texture

		"empty":
			card.texture = null

		_:
			print(
				"Unknown RPS value: ",
				rps
			)


# ========================================
# QUALITY BACKGROUND
# ========================================

func set_quality_background(
	quality: String
) -> void:

	match quality:

		"poor":
			portrait_background.texture = poor_background

		"common":
			portrait_background.texture = common_background

		"rare":
			portrait_background.texture = rare_background

		"unique":
			portrait_background.texture = unique_background

		_:
			print(
				"Unknown goat quality: ",
				quality
			)


# ========================================
# REJECT / NEXT GOAT
# ========================================

func _on_reject_pressed() -> void:

	current_goat_index += 1

	if current_goat_index >= goats.size():

		print("No more goats.")

		reject_button.disabled = true
		match_button.disabled = true

		return

	display_goat(
		goats[current_goat_index]
	)


# ========================================
# MATCH GOAT
# ========================================

func _on_match_pressed() -> void:

	if current_goat_index < 0:
		return

	if current_goat_index >= goats.size():
		return


	# --------------------------------
	# GOAT 1
	#
	# This is the exact goat currently
	# being displayed to the player.
	# --------------------------------

	var matched_goat: Dictionary = goats[
		current_goat_index
	].duplicate(true)


	# --------------------------------
	# GOAT 2
	#
	# Generate a completely random goat
	# using the normal GoatGenerator.
	#
	# This means Goat2 gets:
	# - Random type
	# - Random quality
	# - Quality-based Null / Anti
	# - Random Set 2
	# - Temporary random Set 3
	# --------------------------------

	var enemy_goat: Dictionary = GoatGenerator.generate_goat(
		randi()
	)


	if enemy_goat.is_empty():

		print(
			"ERROR: Could not generate Goat2."
		)

		return


	# --------------------------------
	# STORE THE MATCH
	#
	# Goat1 = matched goat
	# Goat2 = random generated opponent
	# --------------------------------

	GoatMatchData.set_match_goats(
		matched_goat,
		enemy_goat
	)


	# --------------------------------
	# DEBUG
	# --------------------------------

	print("==============================")
	print("MATCH STARTING")
	print("==============================")

	print(
		"GOAT 1: ",
		matched_goat["name"],
		" | ",
		matched_goat["quality"]
	)

	print(
		"GOAT 1 SET 1: ",
		matched_goat["set_1"]
	)

	print(
		"GOAT 1 SET 2: ",
		matched_goat["set_2"]
	)

	print(
		"GOAT 1 SET 3: ",
		matched_goat["set_3"]
	)

	print("------------------------------")

	print(
		"GOAT 2: ",
		enemy_goat["name"],
		" | ",
		enemy_goat["quality"]
	)

	print(
		"GOAT 2 SET 1: ",
		enemy_goat["set_1"]
	)

	print(
		"GOAT 2 SET 2: ",
		enemy_goat["set_2"]
	)

	print(
		"GOAT 2 SET 3: ",
		enemy_goat["set_3"]
	)

	print("==============================")


	# --------------------------------
	# GO TO COMBAT
	# --------------------------------

	get_tree().change_scene_to_file(
		"res://goat_combat.tscn"
	)


func _on_match_button_pressed() -> void:
	pass # Replace with function body.

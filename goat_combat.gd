extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var goat1: CharacterBody2D = $Goat1
@onready var goat2: CharacterBody2D = $Goat2
@onready var goat1_hp_bar: Control = $CanvasLayer/Goat1HPBar
@onready var goat2_hp_bar: Control = $CanvasLayer/Goat2HPBar

@export var shake_duration: float = 0.2
@export var shake_strength: float = 20.0

var floating_text_scene = preload(
	"res://GoatFighter/Scripts/floating_text.tscn"
)

# ========================================
# RPS TEXTURES FOR VISUAL REVEAL
# ========================================
var rps_textures = {
	"rock": preload("res://GoatFighter/RPS/Rock.png"),
	"paper": preload("res://GoatFighter/RPS/Paper.png"),
	"scissors": preload("res://GoatFighter/RPS/Scissors.png"),
	"anti": preload("res://GoatFighter/RPS/Anti.png"),
	"null": preload("res://GoatFighter/RPS/Null.png")
}

var shake_timer: float = 0.0

var goat1_hp: int = 3
var goat2_hp: int = 3

var combat_over := false
var bonk_locked := false

var goat1_data: Dictionary = {}
var goat2_data: Dictionary = {}


func _ready() -> void:
	add_to_group("camera_shaker")

	# ========================================
	# GET GOATS FROM GOAT MATCHING
	# ========================================

	if GoatMatchData.has_match():

		goat1_data = GoatMatchData.goat1_data.duplicate(true)
		goat2_data = GoatMatchData.goat2_data.duplicate(true)

		assign_goat(goat1, goat1_data)
		assign_goat(goat2, goat2_data)

		print("================================")
		print("MATCH DATA LOADED")
		print("================================")

		print("Goat 1: ", goat1_data["name"], " | ", goat1_data["quality"])
		print("Goat 1 Set 1: ", goat1_data["set_1"])
		print("Goat 1 Set 2: ", goat1_data["set_2"])
		print("Goat 1 Set 3: ", goat1_data["set_3"])

		print("--------------------------------")

		print("Goat 2: ", goat2_data["name"], " | ", goat2_data["quality"])
		print("Goat 2 Set 1: ", goat2_data["set_1"])
		print("Goat 2 Set 2: ", goat2_data["set_2"])
		print("Goat 2 Set 3: ", goat2_data["set_3"])

		print("================================")

	else:

		# --------------------------------
		# FALLBACK FOR DIRECT TESTING
		# --------------------------------

		print("No match data found. Generating random goats for testing.")

		goat1_data = GoatGenerator.generate_goat(randi())
		goat2_data = GoatGenerator.generate_goat(randi())

		assign_goat(goat1, goat1_data)
		assign_goat(goat2, goat2_data)


	# ========================================
	# DYNAMICALLY SETUP INITIAL HP BARS
	# ========================================

	goat1_hp = goat1_data["hp"]
	goat2_hp = goat2_data["hp"]

	if goat1_hp_bar and goat1_hp_bar.has_method("setup_hp"):
		goat1_hp_bar.setup_hp(goat1_hp)

	if goat2_hp_bar and goat2_hp_bar.has_method("setup_hp"):
		goat2_hp_bar.setup_hp(goat2_hp)

	print("Goat 1 HP: ", goat1_hp)
	print("Goat 2 HP: ", goat2_hp)


func assign_goat(
	goat: CharacterBody2D,
	goat_data: Dictionary
) -> void:

	if goat_data.is_empty():
		print("ERROR: Empty goat data for ", goat.name)
		return

	if goat.has_node("Sprite2D"):
		goat.get_node("Sprite2D").texture = goat_data["portrait"]

	print(goat.name, " assigned ", goat_data["name"], " | ", goat_data["quality"])


func damage_goat(
	goat: CharacterBody2D
) -> void:

	if combat_over:
		return

	if goat == goat1:

		goat1_hp = max(goat1_hp - 1, 0)

		if goat1_hp_bar and goat1_hp_bar.has_method("set_hp"):
			goat1_hp_bar.set_hp(goat1_hp)

		show_damage_number(goat1)

		print("Goat 1 HP: ", goat1_hp)

	elif goat == goat2:

		goat2_hp = max(goat2_hp - 1, 0)

		if goat2_hp_bar and goat2_hp_bar.has_method("set_hp"):
			goat2_hp_bar.set_hp(goat2_hp)

		show_damage_number(goat2)

		print("Goat 2 HP: ", goat2_hp)


	# ========================================
	# CHECK FOR FINAL HIT
	# ========================================

	if goat1_hp <= 0 or goat2_hp <= 0:

		combat_over = true

		print("================================")
		print("COMBAT OVER!")
		print("================================")

		stop_combat()


func show_damage_number(
	goat: CharacterBody2D
) -> void:

	if floating_text_scene == null:
		return

	var floating_text = floating_text_scene.instantiate()
	goat.add_child(floating_text)
	floating_text.position = Vector2(-20, -200)


func stop_combat() -> void:

	goat1.velocity = Vector2.ZERO
	goat2.velocity = Vector2.ZERO

	goat1.set_collision_layer(0)
	goat1.set_collision_mask(0)

	goat2.set_collision_layer(0)
	goat2.set_collision_mask(0)


# ========================================
# SHOW FLOATING RPS ICON ON BONK
# ========================================

func show_rps_icon(goat: CharacterBody2D, move_name: String) -> void:
	if not rps_textures.has(move_name):
		return

	var sprite := Sprite2D.new()
	sprite.texture = rps_textures[move_name]
	sprite.global_position = goat.global_position + Vector2(0, -60)
	sprite.scale = Vector2(0.2, 0.2)
	
	add_child(sprite)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "global_position:y", sprite.global_position.y - 40, 0.6)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(sprite.queue_free)


func resolve_bonk(
	attacker: CharacterBody2D,
	defender: CharacterBody2D
) -> void:

	if combat_over or bonk_locked:
		return

	bonk_locked = true

	# Always sample moves explicitly from Goat 1 (Player) and Goat 2 (Enemy)
	var goat1_move = get_random_rps_move(goat1)
	var goat2_move = get_random_rps_move(goat2)

	# --- REVEAL RPS ICONS ---
	show_rps_icon(goat1, goat1_move)
	show_rps_icon(goat2, goat2_move)

	print("================================")
	print("BONK!")
	print("Goat 1 (Player): ", goat1_move)
	print("Goat 2 (Enemy): ", goat2_move)


	# ========================================
	# EVALUATE MATCHUP VIA GOATDATABASE
	# ========================================

	var result = GoatDatabase.evaluate_matchup(goat1_move, goat2_move)

	match result:

		GoatDatabase.Result.DRAW:
			print("DRAW! No damage.")

			if goat1.has_method("start_bounce"):
				goat1.start_bounce(false)
			if goat2.has_method("start_bounce"):
				goat2.start_bounce(false)

		GoatDatabase.Result.WIN:
			print("Goat 1 WINS!")

			damage_goat(goat2)

			if goat1.has_method("start_bounce"):
				goat1.start_bounce(false)

			if goat2.has_method("start_bounce"):
				goat2.start_bounce(true)

		GoatDatabase.Result.LOSE:
			print("Goat 2 WINS!")

			damage_goat(goat1)

			if goat2.has_method("start_bounce"):
				goat2.start_bounce(false)

			if goat1.has_method("start_bounce"):
				goat1.start_bounce(true)


	print("================================")


	# ========================================
	# UNLOCK NEXT BONK
	# ========================================

	if not combat_over:

		get_tree().create_timer(0.8).timeout.connect(
			func(): bonk_locked = false
		)


func get_random_rps_move(
	goat: CharacterBody2D
) -> String:

	var goat_data: Dictionary

	if goat == goat1:
		goat_data = goat1_data
	else:
		goat_data = goat2_data

	var rps_set: Array = goat_data.get("set_1", ["rock", "paper", "scissors"])

	if rps_set.is_empty():
		return "rock"

	return rps_set.pick_random()


func _process(
	delta: float
) -> void:

	# ========================================
	# CAMERA SHAKE
	# ========================================

	if shake_timer > 0.0:

		shake_timer -= delta

		var current_strength: float = (
			shake_timer / shake_duration
		) * shake_strength

		if camera:
			camera.offset = Vector2(
				randf_range(-current_strength, current_strength),
				randf_range(-current_strength, current_strength)
			)

	elif camera and camera.offset != Vector2.ZERO:

		camera.offset = Vector2.ZERO


func shake_camera(
	custom_duration: float = shake_duration,
	custom_strength: float = shake_strength
) -> void:

	shake_duration = custom_duration
	shake_strength = custom_strength
	shake_timer = custom_duration

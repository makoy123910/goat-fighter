extends CharacterBody2D

@export var speed := 50.0
@export var min_bounce_distance := 40.0
@export var max_bounce_distance := 60.0
@export var bounce_duration := 0.7
@export var jump_height := 35.0
@export var rotations := 1.0

@export var impact_shake_duration := 0.25
@export var impact_shake_strength := 25.0

var direction := 1
var bouncing := false
var bounce_start_position := Vector2.ZERO
var bounce_target_x := 0.0
var bounce_time := 0.0
var ground_y := 0.0
var spin_direction := 1

@onready var sprite = $Sprite2D


func _ready():
	ground_y = global_position.y


func _physics_process(delta):
	# COMBAT FINISHED
	if get_parent().combat_over and not bouncing:
		velocity = Vector2.ZERO
		return


	# NORMAL CHARGE
	if not bouncing:
		velocity.x = speed * direction
		move_and_slide()

		if get_slide_collision_count() > 0:
			var collision = get_slide_collision(0)
			var other = collision.get_collider()

			if other == get_parent().get_node("Goat1") \
			or other == get_parent().get_node("Goat2"):

				get_parent().resolve_bonk(self, other)


	# AIRBORNE BOUNCE
	else:
		bounce_time += delta

		var t: float = clamp(
			bounce_time / bounce_duration,
			0.0,
			1.0
		)

		# Move backward
		global_position.x = lerp(
			bounce_start_position.x,
			bounce_target_x,
			t
		)

		# Jump upward and come back down
		global_position.y = ground_y - (
			sin(t * PI) * jump_height
		)

		# Spin
		sprite.rotation = (
			spin_direction *
			TAU *
			rotations *
			t
		)

		# Land
		if t >= 1.0:
			global_position.y = ground_y
			sprite.rotation = 0.0
			bouncing = false


func start_bounce(should_flip := false):
	bouncing = true
	bounce_time = 0.0

	bounce_start_position = global_position
	ground_y = global_position.y

	# Camera shake
	get_tree().call_group(
		"camera_shaker",
		"shake_camera",
		impact_shake_duration,
		impact_shake_strength
	)

	# Random knockback distance
	var bounce_distance := randf_range(
		min_bounce_distance,
		max_bounce_distance
	)

	bounce_target_x = (
		global_position.x
		- direction * bounce_distance
	)

	# Winner = no flip
	# Loser = flip
	if should_flip:
		spin_direction = 1 if randf() > 0.5 else -1
	else:
		spin_direction = 0

extends Control

@export var float_distance := 30.0
@export var duration := 1

@onready var label: Label = $Label


func _ready() -> void:
	var start_position := position
	var end_position := start_position + Vector2(0, -float_distance)

	var tween := create_tween()

	# Slight pop when it appears
	tween.tween_property(
		self,
		"scale",
		Vector2(1.2, 1.2),
		0.08
	)

	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.08
	)

	# Float upward
	tween.parallel().tween_property(
		self,
		"position",
		end_position,
		duration
	)

	# Fade out
	tween.parallel().tween_property(
		label,
		"modulate:a",
		0.0,
		duration
	)

	# Delete when finished
	tween.finished.connect(queue_free)

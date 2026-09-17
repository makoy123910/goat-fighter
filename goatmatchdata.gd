extends Node

var goat1_data: Dictionary = {}
var goat2_data: Dictionary = {}


func set_match_goats(goat1: Dictionary, goat2: Dictionary) -> void:
	goat1_data = goat1.duplicate(true)
	goat2_data = goat2.duplicate(true)


func clear_match() -> void:
	goat1_data.clear()
	goat2_data.clear()


func has_match() -> bool:
	return not goat1_data.is_empty()

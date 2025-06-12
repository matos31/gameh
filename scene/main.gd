extends Node2D



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/game.tscn")


func _on_how_to_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/tutorial.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/credits.tscn") # Replace with function body.

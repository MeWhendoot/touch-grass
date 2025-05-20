extends Node2D

var current_level_name: String = "RED_HAZE"

signal IncrementScore(incr: int)

signal IncrementCombo()
signal ResetCombo()
signal NoteJudged(score_value: float)

signal CreateNote(button_name: String, travel_time: float) # Include travel time
signal HitlinePress(button_name: String, array_num: int)

signal NoteMissed

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			# Change to the main menu scene
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

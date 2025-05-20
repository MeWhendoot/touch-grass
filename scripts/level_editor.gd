extends Node2D
class_name LevelEditor

@onready var game_ui_scene = load("res://scenes/game_ui.tscn") # Store the scene, not an instance

# Set this constant before game start
@export var in_edit_mode: bool = false
var current_level_name: String = Signals.current_level_name

# Time it takes for note to reach the hitline (jumpspeed/approachrate)
var note_travel_time: float = 1.2
var note_output_arr = [[], [], [], []]

var level_info = LevelData.level_info

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicPlayer.stream = level_info.get(current_level_name).get("music")
	$MusicPlayer.set_volume_db(-20.0)
	$MusicPlayer.play() # Play music regardless of edit mode

	var global_start_offset: float = OptionsManager.get_start_offset()

	if in_edit_mode:
		Signals.HitlinePress.connect(HitlinePress)

	else:
		var note_offsets_str = level_info.get(current_level_name).get("note_offsets")
		var note_offsets_arr = str_to_var(note_offsets_str)

		var counter: int = 0
		for note_lane in note_offsets_arr:
			var button_name: String = ""
			match counter:
				0:
					button_name = "Lane1"
				1:
					button_name = "Lane2"
				2:
					button_name = "Lane3"
				3:
					button_name = "Lane4"

			for original_delay in note_lane:
				var spawn_time = original_delay + global_start_offset
				if spawn_time >= 0:
					SpawnNote(button_name, spawn_time, note_travel_time) # Pass travel time

			counter += 1

func HitlinePress(button_name: String, array_num: int):
	note_output_arr[array_num].append($MusicPlayer.get_playback_position() - note_travel_time) # Use travel time

func SpawnNote(button_name: String, delay: float, travel_time: float):
	if delay >= 0:
		await get_tree().create_timer(delay).timeout
		Signals.CreateNote.emit(button_name, travel_time) # Emit travel time

func _on_music_player_finished() -> void:
	print(note_output_arr)

	var results_scene = preload("res://scenes/results_screen.tscn")
	var results_instance = results_scene.instantiate()
	get_tree().current_scene.add_child(results_instance)
	
	var game_ui_instance = get_node_or_null("GameUI")
	if game_ui_instance:
		var score = game_ui_instance.score
		var accuracy = game_ui_instance.total_score_received / (game_ui_instance.total_notes * game_ui_instance.max_hit_score) if game_ui_instance.total_notes > 0 else 1.0
		var miss_count = game_ui_instance.miss_count

		results_instance.set_results(score, accuracy, miss_count, current_level_name)
	else:
		print("Error: GameUI instance not found")

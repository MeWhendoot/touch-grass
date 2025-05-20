extends Control

@onready var score_label = $ScoreLabel
@onready var accuracy_label = $AccuracyLabel
@onready var combo_label = $ComboLabel
@onready var rank_label = $RankLabel

func _ready() -> void:
	# Debugging visibility of the labels
	if score_label == null:
		print("Error: ScoreLabel not found.")
	if accuracy_label == null:
		print("Error: AccuracyLabel not found.")
	if combo_label == null:
		print("Error: ComboLabel not found.")
	if rank_label == null:
		print("Error: RankLabel not found.")

	# Debugging if the scene itself is ready and added
	if is_inside_tree():
		print("Results screen is in the scene tree!")
	else:
		print("Results screen is NOT in the scene tree!")

	# Hardcoding values to ensure labels are updated
	score_label.text = "Score: 12345"
	accuracy_label.text = "Accuracy: 98.76%"
	combo_label.text = "Max Combo: 32x"
	rank_label.text = "S"

	# Debugging values
	print("Score: 12345, Accuracy: 98.76, Max Combo: 32")

# This function will receive the results from the previous scene
func set_results(score: int, accuracy: float, miss_count: int, level_key: String):
	if score_label:
		score_label.text = "[right]Score: %d" % score
	if accuracy_label:
		accuracy_label.text = "[right]Accuracy: %.2f%%" % (accuracy * 100.0)
	if combo_label:
		if miss_count == 0:
			combo_label.text = "[right]FULL COMBO"
		else:
			combo_label.text = "[right]Misses: %d" % miss_count
	if rank_label:
		rank_label.text = "[right]" + calculate_rank(accuracy)

	# Save results to config file
	save_results(level_key, score, accuracy, miss_count)

	# Debug
	print("Score: %d, Accuracy: %.2f, Miss Count: %d, Level: %s" % [score, accuracy, miss_count, level_key])

func calculate_rank(accuracy: float) -> String:
	if accuracy >= 1.0:
		return "SSS"
	elif accuracy >= 0.98:
		return "SS"
	elif accuracy >= 0.90:
		return "S"
	elif accuracy >= 0.80:
		return "A"
	elif accuracy >= 0.70:
		return "B"
	elif accuracy >= 0.60:
		return "C"
	else:
		return "D"

func save_results(level_key: String, score: int, accuracy: float, miss_count: int) -> void:
	var config = ConfigFile.new()
	var path = "user://scores.cfg"
	var section = "scores"
	var saved_score := 0
	var saved_accuracy := 0.0
	var saved_miss_count := -1 # Initialize to a value that won't be a valid miss count

	# Try to load config, but continue even if it doesn't exist yet
	var err := config.load(path)

	# If the file exists but cannot be opened
	if err != OK and err != ERR_DOES_NOT_EXIST:
		printerr("Failed to load scores config:", err)
		return

	# Read old results if they exist
	if config.has_section_key(section, level_key):
		var existing_data = config.get_value(section, level_key)
		if typeof(existing_data) == TYPE_DICTIONARY:
			saved_score = int(existing_data.score)
			saved_accuracy = float(existing_data.accuracy)
			saved_miss_count = int(existing_data.misses)
		else:
			# Handle legacy single score entries, or reset if the format is unexpected
			saved_score = int(existing_data)
			saved_accuracy = 0.0
			saved_miss_count = -1
			print("Warning: Legacy score format found for", level_key, ". Accuracy and misses will not be compared.")

	# Save only if the new score is better
	if score > saved_score:
		var save_data = {
			"score": score,
			"accuracy": accuracy,
			"misses": miss_count
		}
		config.set_value(section, level_key, save_data)

		# Ensure the `user://` directory exists
		var dir := DirAccess.open("user://")
		if dir == null:
			var create_err := DirAccess.make_dir_recursive_absolute("user://")
			if create_err != OK:
				printerr("Could not create user directory:", create_err)
				return

		# Save the updated config
		var save_err := config.save(path)
		if save_err != OK:
			printerr("Failed to save scores config:", save_err)
		else:
			print("Results saved for", level_key, ": Score =", score, ", Accuracy =", accuracy, ", Misses =", miss_count)
	else:
		print("Score not saved. Existing high score is higher or equal:", saved_score)

extends Control

var level_editor_script = load("res://scripts/level_editor.gd")
var level_info = LevelData.level_info

func _ready():
	var container = $ScrollContainer/LevelListContainer

	# Load the custom font
	var my_font = load("res://assets/fonts/Bread_Smile.ttf")

	# Load saved scores from config
	var config = ConfigFile.new()
	var config_path = "user://scores.cfg"
	var err = config.load(config_path)
	if err != OK and err != ERR_DOES_NOT_EXIST:
		printerr("Failed to load scores config:", err)

	for level_key in level_info.keys():
		if level_key == "TEMPLATE":
			continue
		if level_key == "TEST":
			continue

		var level = level_info[level_key]

		# Create the button
		var row_button = Button.new()
		row_button.focus_mode = Control.FOCUS_NONE
		row_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_button.custom_minimum_size = Vector2(0, 100)

		# Theme override for visibility
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
		row_button.add_theme_stylebox_override("normal", style)

		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.3, 0.3, 0.3, 0.7)
		row_button.add_theme_stylebox_override("hover", hover_style)

		# HBox for cover + text
		var row_layout = HBoxContainer.new()
		row_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_layout.size_flags_vertical = Control.SIZE_FILL

		# Cover art
		var art = TextureRect.new()
		art.texture = level["cover_art"]
		art.expand = true
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.custom_minimum_size = Vector2(100, 100)
		row_layout.add_child(art)

		# Label with name, artist, and score
		var label = Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", my_font)

		var score_display := ""
		var accuracy_display := ""
		var misses_display := ""

		if config.has_section_key("scores", level_key):
			var level_results = config.get_value("scores", level_key)
			if typeof(level_results) == TYPE_DICTIONARY:
				var score = int(level_results.score)
				var accuracy = float(level_results.accuracy) * 100.0
				var misses = int(level_results.misses)

				score_display = " // High Score: %d" % score
				accuracy_display = ", %.2f%%" % accuracy
				misses_display = ", Misses: %d" % misses
			else:
				# Handle legacy single score entries
				score_display = " // High Score: %d" % int(level_results)
				accuracy_display = ", N/A"
				misses_display = ", Misses: N/A"

		label.text = "%s\n%s%s%s%s" % [level["name"], level["artist"], score_display, accuracy_display, misses_display]

		row_layout.add_child(label)

		row_button.add_child(row_layout)
		row_button.pressed.connect(_on_level_button_pressed.bind(level_key))
		container.add_child(row_button)

func _on_level_button_pressed(level_key: String) -> void:
	print("Selected level: ", level_key)

	# Set the level name in the Global singleton
	Signals.current_level_name = level_key

	# Transition to the GameScene
	get_tree().change_scene_to_file("res://scenes/game.tscn") # Change to your game scene path

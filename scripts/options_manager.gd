class_name OptionsManager1
extends Node

var global_start_offset: float = 0.0
const CONFIG_FILE_PATH: String = "user://game_options.cfg"
const SCORES_CONFIG_PATH: String = "user://scores.cfg"
const START_OFFSET_KEY: String = "start_offset"
const OPTIONS_SECTION: String = "game"

var keybinds := DEFAULT_KEYBINDS.duplicate()
const KEYBINDS_SECTION := "keybinds"
const DEFAULT_KEYBINDS := {
	"Lane1": "D",
	"Lane2": "F",
	"Lane3": "J",
	"Lane4": "K",
}

func set_keybind(action: String, key: String) -> void:
	keybinds[action] = key
	_update_input_map()
	save_options()

func get_keybind(action: String) -> String:
	return keybinds.get(action, "")

func _update_input_map() -> void:
	for action in DEFAULT_KEYBINDS.keys():
		if InputMap.has_action(action):
			for event in InputMap.action_get_events(action):
				InputMap.action_erase_event(action, event)

		var key_string: String = keybinds.get(action, "")
		if key_string != "":
			var key_event := InputEventKey.new()
			key_event.physical_keycode = OS.find_keycode_from_string(key_string)
			InputMap.action_add_event(action, key_event)

func _ready() -> void:
	load_options()
	create_scores_config_if_missing()

func set_start_offset(offset: float) -> void:
	global_start_offset = offset
	save_options()
	print("Global start offset set to:", global_start_offset)

func get_start_offset() -> float:
	return global_start_offset

func save_options() -> void:
	var config = ConfigFile.new()
	config.set_value(OPTIONS_SECTION, START_OFFSET_KEY, global_start_offset)

	for action in keybinds.keys():
		config.set_value(KEYBINDS_SECTION, action, keybinds[action])

	var err = config.save(CONFIG_FILE_PATH)
	if err != OK:
		printerr("Error saving configuration file:", err)

func load_options() -> void:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	if err == OK:
		if config.has_section(OPTIONS_SECTION):
			if config.has_section_key(OPTIONS_SECTION, START_OFFSET_KEY):
				global_start_offset = config.get_value(OPTIONS_SECTION, START_OFFSET_KEY)

		if config.has_section(KEYBINDS_SECTION):
			for action in DEFAULT_KEYBINDS.keys():
				if config.has_section_key(KEYBINDS_SECTION, action):
					keybinds[action] = config.get_value(KEYBINDS_SECTION, action)

		_update_input_map()
	else:
		print("No existing config, saving default.")
		save_options()

func create_scores_config_if_missing() -> void:
	var config := ConfigFile.new()
	var err := config.load(SCORES_CONFIG_PATH)
	if err != OK:
		var save_err := config.save(SCORES_CONFIG_PATH)
		if save_err != OK:
			printerr("Failed to create scores config:", save_err)
		else:
			print("Created new scores config at:", SCORES_CONFIG_PATH)
	else:
		print("Scores config exists.")

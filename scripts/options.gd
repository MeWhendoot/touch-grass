extends Control

@onready var start_offset_input: LineEdit = %StartOffsetInput
@onready var save_options_button: Button = %SaveOptionsButton

@onready var lane1_input := $Keybinds/Lane1Input  # LineEdit
@onready var lane2_input := $Keybinds/Lane2Input
@onready var lane3_input := $Keybinds/Lane3Input
@onready var lane4_input := $Keybinds/Lane4Input

func _ready() -> void:
	start_offset_input.text = str(OptionsManager.get_start_offset())

	# Load keybinds into LineEdits
	lane1_input.text = OptionsManager.get_keybind("Lane1")
	lane2_input.text = OptionsManager.get_keybind("Lane2")
	lane3_input.text = OptionsManager.get_keybind("Lane3")
	lane4_input.text = OptionsManager.get_keybind("Lane4")

	save_options_button.pressed.connect(_on_save_options_button_pressed)

func _on_save_options_button_pressed() -> void:
	var offset = start_offset_input.text.to_float()
	OptionsManager.set_start_offset(offset)

	OptionsManager.set_keybind("Lane1", lane1_input.text)
	OptionsManager.set_keybind("Lane2", lane2_input.text)
	OptionsManager.set_keybind("Lane3", lane3_input.text)
	OptionsManager.set_keybind("Lane4", lane4_input.text)

	print("Options saved.")

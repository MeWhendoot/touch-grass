extends Control

var score: int = 0
var combo_count: int = 0
var max_combo: int = 0
var miss_count: int = 0

var total_notes: int = 0
var total_score_received: float = 0.0
var max_hit_score: float = 250.0  # Assuming 'perfect' is 250

# Timer-related variables
var song_length: float = 0.0
var time_left: float = 0.0
var countdown_active: bool = false

func _ready() -> void:
	Signals.IncrementScore.connect(IncrementScore)
	Signals.IncrementCombo.connect(IncrementCombo)
	Signals.ResetCombo.connect(ResetCombo)
	Signals.NoteJudged.connect(OnNoteJudged)
	Signals.NoteMissed.connect(on_note_missed)
	
	ResetCombo()
	UpdateAccuracyDisplay()
	
	var level_name := Signals.current_level_name
	if LevelData.level_info.has(level_name):
		var raw_length = LevelData.level_info[level_name].get("song_length", 0.0)
		
		# Convert from decimal format (e.g. 3.33) to seconds
		var minutes = int(raw_length)
		var seconds = (raw_length - minutes) * 100
		time_left = (minutes * 60) + seconds

		countdown_active = true
		update_timer_label()

func _process(delta: float) -> void:
	if countdown_active:
		time_left -= delta
		if time_left < 0:
			time_left = 0
			countdown_active = false
		update_timer_label()

func IncrementScore(incr: int):
	score += incr
	%ScoreLabel.text = "Score : " + str(score)

func IncrementCombo():
	combo_count += 1
	if combo_count > max_combo:
		max_combo = combo_count
	%ComboLabel.text = str(combo_count) + "x"

func ResetCombo():
	combo_count = 0
	%ComboLabel.text = "0x"

func OnNoteJudged(judgement_value: float):
	total_notes += 1
	total_score_received += judgement_value
	UpdateAccuracyDisplay()

func UpdateAccuracyDisplay():
	if total_notes == 0:
		%AccuracyLabel.text = "100.00%"
		return
	
	var max_total = total_notes * max_hit_score
	var accuracy = total_score_received / max_total
	accuracy = clamp(accuracy, 0.0, 1.0)
	
	%AccuracyLabel.text = "%0.2f%%" % (accuracy * 100.0)

func on_note_missed():
	miss_count += 1

func update_timer_label():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	%TimeLabel.text = "[right]%02d:%02d" % [minutes, seconds]

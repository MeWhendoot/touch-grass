extends Sprite2D

@onready var note = preload("res://scenes/note.tscn")
@onready var score_text = preload("res://scenes/score_hit_text.tscn")
@export var lane_name: String = ""

var note_queue = []

# Hit thresholds in pixels
var perfect_hit_threshold: float = 30
var good_hit_threshold: float = 70
var ok_hit_threshold: float = 100
@export var miss_leniency: float = 40.0

# Score values
var perfect_hit_score: float = 250
var good_hit_score: float = 100
var ok_hit_score: float = 50

func _ready():
	$GlowOverlay.frame = frame + 4
	Signals.CreateNote.connect(CreateNote)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(lane_name):
		Signals.HitlinePress.emit(lane_name, frame)

	if note_queue.size() > 0:
		var front_note = note_queue.front()

		# Check if note missed
		if front_note.global_position.y > front_note.pass_threshold + miss_leniency:
			note_queue.pop_front()
			front_note.queue_free()

			# Show MISS text
			var st_inst = score_text.instantiate()
			get_tree().get_root().call_deferred("add_child", st_inst)
			st_inst.SetTextInfo("MISS")
			st_inst.global_position = global_position + Vector2(0, -20)

			Signals.ResetCombo.emit()
			Signals.NoteJudged.emit(0.0)
			Signals.NoteMissed.emit()

		elif Input.is_action_just_pressed(lane_name):
			var _distance_from_pass = abs(front_note.pass_threshold - front_note.global_position.y)

			if _distance_from_pass < ok_hit_threshold:
				note_queue.pop_front()
				$AnimationPlayer.stop()
				$AnimationPlayer.play("note_hit")

				var hit_score_text: String = ""

				if _distance_from_pass < perfect_hit_threshold:
					Signals.IncrementScore.emit(perfect_hit_score)
					Signals.IncrementCombo.emit()
					Signals.NoteJudged.emit(perfect_hit_score)
					hit_score_text = "PERFECT"

				elif _distance_from_pass < good_hit_threshold:
					Signals.IncrementScore.emit(good_hit_score)
					Signals.IncrementCombo.emit()
					Signals.NoteJudged.emit(good_hit_score)
					hit_score_text = "GOOD"

				else:
					Signals.IncrementScore.emit(ok_hit_score)
					Signals.IncrementCombo.emit()
					Signals.NoteJudged.emit(ok_hit_score)
					hit_score_text = "OK"

				# Remove the note
				front_note.queue_free()

				# Show hit score text
				var st_inst = score_text.instantiate()
				get_tree().get_root().call_deferred("add_child", st_inst)
				st_inst.SetTextInfo(hit_score_text)
				st_inst.global_position = global_position + Vector2(0, -20)

			else:
				# Not a valid hit range, treat as a MISS
				#Signals.ResetCombo.emit()
				Signals.NoteJudged.emit(0.0)

func CreateNote(button_name: String, travel_time: float):
	if button_name == lane_name:
		var note_inst = note.instantiate()
		get_tree().get_root().call_deferred("add_child", note_inst)
		note_inst.Setup(position.x, frame + 4, travel_time)

		note_queue.push_back(note_inst)

func _on_random_spawn_timer_timeout() -> void:
	$RandomSpawnTimer.wait_time = randf_range(0.4, 3)
	$RandomSpawnTimer.start()

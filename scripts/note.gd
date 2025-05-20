extends Sprite2D

var fall_speed: float = 6.0 # Will be calculated
var init_y_pos: float = -360
var travel_time: float

var has_passed: bool = false
var pass_threshold = 300.0

func _init():
	set_process(false)

func _process(delta: float) -> void:
	global_position += Vector2(0, fall_speed * delta) # No scaling factor

	if global_position.y > pass_threshold and not $Timer.is_stopped():
		$Timer.stop()
		has_passed = true

func Setup(target_x: float, target_frame: int, travel_time: float):
	global_position = Vector2(target_x, init_y_pos)
	frame = target_frame
	self.travel_time = travel_time

	# Calculate fall speed based on distance and desired travel time
	var distance_to_hitline = pass_threshold - init_y_pos
	if travel_time > 0:
		fall_speed = distance_to_hitline / travel_time
	else:
		fall_speed = 100.0 # Default speed if travel time is invalid

	set_process(true)

func _on_destroy_timer_timeout() -> void:
	queue_free()

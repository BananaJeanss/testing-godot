extends AnimatedSprite2D

@onready var audio_player = $AudioStreamPlayer2D

var is_animation_done = false
var is_audio_done = false

func _ready():
	self.animation_finished.connect(_on_animation_finished)
	audio_player.finished.connect(_on_audio_finished)

	self.play("Explosion")
	audio_player.play()

func _on_animation_finished():
	is_animation_done = true
	try_to_queue_free()

func _on_audio_finished():
	is_audio_done = true
	try_to_queue_free()

func try_to_queue_free():
	# this function checks if both animation and the audio are done
	if is_animation_done and is_audio_done:
		queue_free()

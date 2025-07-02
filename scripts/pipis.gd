extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var despawn_timer: Timer = $DespawnTimer
@onready var blink_timer: Timer = $BlinkTimer

signal collected

var blink_state := false

func _ready():
	print("Pipis ready")
	connect("body_entered", Callable(self, "_on_body_entered"))
	despawn_timer.start(30)
	despawn_timer.timeout.connect(_on_despawn_timeout)
	blink_timer.timeout.connect(_on_blink_timeout)

func _on_body_entered(body):
	print("body_entered! name: ", body.name)
	if body.name == "Player":
		print("Player collected the pipis! Emitting collected signal.")
		collected.emit()
		queue_free()

func _on_despawn_timeout():
	print("Pipis despawned")
	queue_free()

func _on_blink_timeout():
	blink_state = !blink_state
	sprite.visible = blink_state

func start_blinking():
	print("Pipis is blinking!")
	blink_timer.start(0.2)

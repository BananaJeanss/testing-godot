extends Area2D

const SPEED = 3500
var direction = Vector2.RIGHT

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	position += direction * SPEED * delta
	rotation = direction.angle()

func _on_body_entered(body):
	# Ignore collisions with the player character.
	if body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(1)
	queue_free()

func _on_area_entered(area):
	# Ignore collisions with the player's gun or other player-related areas.
	if area.is_in_group("player"):
		return
	if area.has_method("take_damage"):
		area.take_damage(1)
	queue_free()

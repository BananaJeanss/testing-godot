extends Area2D

const SPEED = 500
var player
var health = 5

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * SPEED * delta

func take_damage(damage):
	health -= damage
	if health <= 0:
		var main_node = get_tree().get_root().get_node("Node2D")
		if main_node:
			main_node.update_score(1500) # adds score on kill
		queue_free()
	else:
		# Red flash effect
		$Sprite2D.modulate = Color(1, 0, 0, 1)
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color(1, 1, 1, 1)

func _on_body_entered(body):
	if body.is_in_group("player"):
		HealthManager.take_damage(20)
		queue_free()

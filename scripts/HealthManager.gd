extends Node

signal health_changed(new_health)
signal max_health_changed(new_max_health)
signal player_died

var health = 100
var max_health = 100
var regen_rate = 1 
var regen_delay = 3
var regen_delay_timer = 0.0

func _ready():
	emit_signal("health_changed", health)
	emit_signal("max_health_changed", max_health)
	regen_delay_timer = regen_delay # Start with regen on

func _process(delta):
	if health < max_health:
		if regen_delay_timer > 0:
			regen_delay_timer -= delta
		else:
			heal(regen_rate * delta)

func take_damage(amount):
	health = max(0, health - amount)
	if health == 0:
		emit_signal("player_died")
	emit_signal("health_changed", health)
	regen_delay_timer = regen_delay # Reset timer on damage

func heal(amount):
	health = min(max_health, health + amount)
	emit_signal("health_changed", health)

func set_max_health(new_max_health):
	max_health = new_max_health
	health = min(health, max_health)
	emit_signal("max_health_changed", max_health)
	emit_signal("health_changed", health)

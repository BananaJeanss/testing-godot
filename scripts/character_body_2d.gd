extends CharacterBody2D

# Preload the scene file for the explosion.
# Drag the scene from the FileSystem dock to get the correct path!
var explosion_scene = preload("res://explosion_effect.tscn")
var bullet_scene = preload("res://bullet.tscn")

const SPEED = 1800.0
const JUMP_VELOCITY = -3000.0
const MAX_JUMPS = 2

signal double_jump_performed

var jump_count = 0
var can_fire = true
var fire_rate = 0.2 # seconds between shots

func _physics_process(delta: float) -> void:
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0  # Reset jumps on landing

	# Handle jumping
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		# Check if this is the double jump
		if jump_count == 1:
			spawn_explosion()
			double_jump_performed.emit() # Emit signal for double jump

		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Handle horizontal movement
	var direction := Input.get_axis("right", "left")
	if direction:
		velocity.x = direction * SPEED
		$Sprite2D.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle firing
	if Input.is_action_pressed("fire") and can_fire:
		fire_bullet()
		can_fire = false
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true

	move_and_slide()

func spawn_explosion():
	var explosion_instance = explosion_scene.instantiate()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = self.global_position

func fire_bullet():
	var fire_sound = $GunPivot/Gun.get_node_or_null("FireSound")
	if fire_sound:
		fire_sound.play()

	var bullet_instance = bullet_scene.instantiate()
	get_parent().add_child(bullet_instance)
	
	var gun_muzzle_position = $GunPivot/Gun.global_position
	bullet_instance.global_position = gun_muzzle_position
	
	var mouse_position = get_global_mouse_position()
	var direction_to_mouse = (mouse_position - gun_muzzle_position).normalized()
	bullet_instance.direction = direction_to_mouse

func _process(_delta):
	rotate_gun_to_mouse()

func rotate_gun_to_mouse():
	var gun_pivot = $GunPivot
	
	var global_mouse_pos = get_global_mouse_position()
	var pivot_global_pos = gun_pivot.global_position
	var to_mouse = global_mouse_pos - pivot_global_pos
	var angle_to_mouse = to_mouse.angle()
	
	# Apply rotation
	gun_pivot.rotation = angle_to_mouse

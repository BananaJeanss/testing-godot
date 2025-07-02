extends Node2D

@onready var top_left = $SpawnArea/TopLeft
@onready var bottom_right = $SpawnArea/BottomRight
@onready var canvas_layer = $CanvasLayer
@onready var pipis_count_label = $CanvasLayer/Pipis/PipisCount
@onready var score_label = $CanvasLayer/Score/Label
@onready var pickup_sound = $PickupSound
@onready var game_over_screen = $gameoverscreen
@onready var game_over_score_label = $gameoverscreen/gameover/score
@onready var game_over_pipis_label = $gameoverscreen/gameover/pipis

@export var pipis_scene: PackedScene
@export var watercooler_scene: PackedScene
var current_pipis = []
var score = 0

func spawn_loop():
	while true:
		await get_tree().create_timer(2.5).timeout # spawn in a watercooler every X seconds
		spawn_pipis_periodically()
		spawn_watercooler()
		
func _ready():
	print("Main script _ready. Score label: ", score_label.name)
	update_score(0)
	spawn_loop()
	
	var player = get_node("Player")
	if player:
		# update score on double jump
		player.double_jump_performed.connect(func(): update_score(10))
	
	var health_manager = get_node("/root/HealthManager")
	if health_manager:
		health_manager.player_died.connect(_on_player_died)
	
	game_over_screen.visible = false

func _on_player_died():
	game_over_score_label.text = "Score: %010d" % score
	var pipis_count = int(pipis_count_label.text.strip_edges().get_slice(":", 1))
	game_over_pipis_label.text = "Pipis collected: %d" % pipis_count
	game_over_screen.visible = true
	get_tree().paused = true

func spawn_pipis_periodically():
	if current_pipis.size() < 3:
		spawn_pipis()

func spawn_pipis():
	print("Spawning pipis...")
	var pipis = pipis_scene.instantiate()
	var x = randf_range(top_left.position.x, bottom_right.position.x)
	var y = randf_range(top_left.position.y, bottom_right.position.y)
	pipis.position = Vector2(x, y)
	print("Pipis spawned at: ", pipis.position)

	add_child(pipis)
	current_pipis.append(pipis)

	# Remove from list on collection
	pipis.collected.connect(func (): 
		update_score(4000)
		print("Pipis collected signal received")
		current_pipis.erase(pipis)
		pickup_sound.play()
		update_pipis_count(1)
	)

	pipis.tree_exited.connect(func ():
		print("Pipis removed from tree")
		current_pipis.erase(pipis)
	)

	await get_tree().create_timer(25.0).timeout
	if is_instance_valid(pipis):
		pipis.start_blinking()


func spawn_watercooler():
	var watercooler = watercooler_scene.instantiate()
	var x = randf_range(top_left.position.x, bottom_right.position.x)
	var y = randf_range(top_left.position.y, bottom_right.position.y)
	watercooler.position = Vector2(x, y)
	add_child(watercooler)

func update_pipis_count(amount):
	var count = int(pipis_count_label.text.strip_edges().get_slice(":", 1))
	count += amount
	pipis_count_label.text = "Pipis: %d" % count

func update_score(amount):
	score += amount
	score_label.text = "Score: %010d" % score # Format with leading zeros
	print("Score updated to: ", score)

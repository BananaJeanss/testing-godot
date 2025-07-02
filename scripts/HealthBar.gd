extends ProgressBar

func _ready():
	HealthManager.health_changed.connect(on_health_changed)
	HealthManager.max_health_changed.connect(on_max_health_changed)

	max_value = HealthManager.max_health
	value = HealthManager.health

	# Set the initial value of the progress bar
	value = HealthManager.health

func on_health_changed(new_health):
	value = new_health

func on_max_health_changed(new_max_health):
	max_value = new_max_health

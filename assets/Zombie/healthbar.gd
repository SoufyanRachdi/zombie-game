extends Control

@onready var bar = $texture_progress_bar
@onready var label = $HealthLabel

func update_health(current, max):
	bar.max_value = max
	bar.value = current
	label.text = "%d/%d" % [current, max]

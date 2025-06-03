extends CanvasLayer

@onready var begin_button := $Panel/BeginButton
@onready var main_panel := $Panel

func _ready():
	main_panel.process_mode = Node.PROCESS_MODE_ALWAYS  # Updated to correct enumget_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if begin_button:
		begin_button.pressed.connect(_on_begin_pressed)
	else:
		print("⚠️ Begin button not found.")

func _on_begin_pressed():
	print("Begin pressed")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

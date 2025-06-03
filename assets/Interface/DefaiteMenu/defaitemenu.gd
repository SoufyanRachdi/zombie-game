extends CanvasLayer

@onready var replay_button: Button = $Panel/replay_button
@onready var menu_button: Button = $Panel/menu_button

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false  # Ensure it starts hidden
	if replay_button or menu_button:
		print("1")
		replay_button.pressed.connect(_on_replay_pressed)
		menu_button.pressed.connect(_on_menu_pressed)
	else:
		print("⚠️ Buttons not found in DefaiteMenu")

func _on_replay_pressed():
	print("Replay pressed")
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().reload_current_scene()

func _on_menu_pressed():
	print("Menu pressed")
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://assets/Interface/Mainmenu/mainmenu.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and visible:
		_on_replay_pressed()

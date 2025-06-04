extends Control

@onready var bar: ProgressBar = $texture_progress_bar
@onready var label = $HealthLabel

@export var anchor_path: NodePath
@export var offset := Vector3.UP * 0.5

var anchor_node: Node3D

func _ready():
	if anchor_path == NodePath(""):
		push_warning("anchor_path is empty! Health bar will not follow any node.")
	else:
		anchor_node = get_node(anchor_path)
		if anchor_node == null:
			push_error("Could not find node at anchor_path: " + str(anchor_path))

func _process(delta):
	if anchor_node:
		var world_position = anchor_node.global_transform.origin + offset
		var camera = get_viewport().get_camera_3d()
		if camera:
			var screen_position = camera.unproject_position(world_position)
			global_position = screen_position

func update_health(current: int, maxh: int):
	bar.max_value = maxh
	bar.value = current
	label.text = "%d / %d" % [current, maxh]

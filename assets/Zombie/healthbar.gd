extends Control

@onready var bar: ProgressBar = $texture_progress_bar
@onready var label = $HealthLabel

@export var anchor_path : NodePath
@export var offset := Vector3.UP * 0.5

var anchor_node: Node3D

func update_health(current, maxh):
	bar.max_value = maxh
	bar.value = current
	label.text = "%d/%d" % [current, maxh]

func _ready():
	anchor_node = get_node(anchor_path)

func _process(delta):
	if anchor_node:
		var world_position = anchor_node.global_transform.origin + offset
		var camera = get_viewport().get_camera_3d()
		if camera:
			var screen_position = camera.unproject_position(world_position)
			global_position = screen_position

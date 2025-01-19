extends Node3D

var mouse_cam_sensitivity = 0.005
var twist_input = 0.0
var pitch_input = 0.0
var input_dir

@onready var twitst_pivot = %h as Node3D
@onready var pitch_pivot = %v as Node3D

@export var min_tilt = deg_to_rad(-45)  # More horizontal view
@export var max_tilt = deg_to_rad(-40)  # Nearly top-down view

func _physics_process(delta: float) -> void:
	twitst_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		min_tilt,
		max_tilt
	)
	print(rad_to_deg(pitch_pivot.rotation.x))
	
	twist_input = 0.0
	pitch_input = 0.0
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_cam_sensitivity
			pitch_input = -event.relative.y * mouse_cam_sensitivity

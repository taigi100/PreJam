extends Node3D

@export var mouse_sensitivity = 0.005
@export var player: NodePath  # Assign the player node in the Inspector

@onready var twist_pivot = $h as Node3D
@onready var pitch_pivot = $h/v as Node3D

@export var min_tilt = deg_to_rad(-45)  # Looking straight down
@export var max_tilt = deg_to_rad(-40)   # Looking straight up

var twist_input = 0.0
var pitch_input = 0.0

func _physics_process(delta: float) -> void:
	if player:
		position = get_node(player).position  # Update camera position to match player

	# Apply rotation inputs
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	
	# Clamp pitch rotation
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, min_tilt, max_tilt)
	
	# Reset inputs
	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity

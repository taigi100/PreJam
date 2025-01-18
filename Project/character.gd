extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 30

@onready var mesh := $MeshInstance3D # Add reference to your mesh instance

var parent

@onready var cam_h = %h as Node3D
@onready var cam_v = %v as Node3D


@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export var min_tilt = deg_to_rad(30)  # More horizontal view
@export var max_tilt = deg_to_rad(85)  # Nearly top-down view

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	parent = get_parent()
	

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
func _process(delta: float) -> void:
	parent.position = position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (cam_h.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), TURN_SPEED * delta)
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()

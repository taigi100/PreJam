extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 30

@onready var mesh := $MeshInstance3D # Add reference to your mesh instance

var parent

var bullet = load("res://enemy/bullet.tscn")
var instance

@onready var cam_h = %h as Node3D
@onready var cam_v = %v as Node3D
@onready var gun_anim = $Weapon/AnimationPlayer
@onready var gun_barrel = $Weapon/RayCast3D

@export_range(0.0, 1.0) var mouse_sensitivity = 0.01

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
	# Transform input direction based on character's rotation
	var move_dir = Vector3.ZERO
	move_dir.x = input_dir.x
	move_dir.z = input_dir.y  # Negative because forward is -Z in Godot
	move_dir = move_dir.rotated(Vector3.UP, rotation.y)
	
	if move_dir:
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Rotate the character to match camera's horizontal rotation
	var target_rotation = cam_h.rotation.y
	rotation.y = lerp_angle(rotation.y, target_rotation, TURN_SPEED * delta)
	
	if Input.is_action_pressed("attack"):
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
		
	
	move_and_slide()

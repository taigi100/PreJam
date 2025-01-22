extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var turn_speed = 30.0
@export var camera_pivot: NodePath  # Assign the camera pivot node in the Inspector

@onready var gun_anim = $Weapon/AnimationPlayer
@onready var gun_barrel = $Weapon/RayCast3D

var bullet = load("res://enemy/bullet.tscn")
var can_shoot = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"): 
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var move_dir = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, rotation.y)

	# Apply movement.
	if move_dir:
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Rotate the character to match camera's horizontal rotation.
	if camera_pivot:
		var cam_h = get_node(camera_pivot).get_node("h")
		rotation.y = lerp_angle(rotation.y, cam_h.rotation.y, turn_speed * delta)

	# Handle shooting.
	if Input.is_action_pressed("attack") and can_shoot:
		shoot()

	move_and_slide()

func shoot():
	if !gun_anim.is_playing():
		gun_anim.play("shoot")
		var instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		can_shoot = false
		await get_tree().create_timer(0.5).timeout  # Cooldown
		can_shoot = true

extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var turn_speed = 30.0
@export var camera_pivot: NodePath  # Assign the camera pivot node in the Inspector
@onready var camera: Camera3D = $Camera3D
@onready var rig: Node3D = $Rig
@onready var gun_barrel: Marker3D = $Rig/Gun_Barrel
#SFX
@onready var AttackSFX = $AttackSFX
@onready var playerDamage = $playerDamage

var bullet = load("res://enemies/common/bullet.tscn")
var can_shoot = true

func _input(event: InputEvent):
	if (Input.mouse_mode != Input.MOUSE_MODE_CONFINED) and event is InputEventMouseButton: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		var cursor_image = load("res://player/Crosshair.png")
		var image = cursor_image.get_image()
		image.resize(48, 48)  # Set your desired dimensions
		var new_texture = ImageTexture.create_from_image(image)
		Input.set_custom_mouse_cursor(new_texture, 
			Input.CURSOR_ARROW,
			Vector2(24, 24))  # Adjust hotspot based on new size

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"): 
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

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
		#gettign the current phyisics state
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()

	var rayOrigin = camera.project_ray_origin(mouse_position)

	var rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * 2000
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	var intersection = space_state.intersect_ray(query)
	if not intersection.is_empty():
		var pos = intersection.position
		rig.look_at(Vector3(pos.x, position.y , pos.z), Vector3(0,1,0))

	# Handle shooting.
	if Input.is_action_pressed("attack") and can_shoot:
		shoot()

	move_and_slide()

func shoot():
	var instance = bullet.instantiate()
	instance.position = gun_barrel.global_position
	instance.transform.basis = gun_barrel.global_transform.basis
	instance.scale = Vector3(1,1,1)
	get_parent().add_child(instance)
	AttackSFX.play()
	can_shoot = false
	await get_tree().create_timer(0.5).timeout  # Cooldown
	can_shoot = true
	

func take_damage(damage):
	print("Player hit with %d damage" % damage)
	playerDamage.play()

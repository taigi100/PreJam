extends Node3D

const SPEED = 40.0
const MAX_BOUNCES = 3

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@export var lifetime = 5.0

var velocity: Vector3
var bounce_count: int = 0

func _ready() -> void:
	velocity = transform.basis * Vector3(0, 0, -SPEED)
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", _death)
	add_child(timer)
	timer.start()

func _process(delta: float) -> void:
	position += velocity * delta
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider.is_in_group("enemy"):
			collider.take_damage(1)
			_death()
		else:
			handle_collision(ray_cast_3d.get_collision_normal())

func handle_collision(collision_normal: Vector3):
	if bounce_count >= MAX_BOUNCES:
		_death()
		return
	velocity = velocity.bounce(collision_normal)
	bounce_count += 1
	look_at(position + velocity.normalized())

func _death():
	queue_free()

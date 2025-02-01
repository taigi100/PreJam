extends CharacterBody3D


var player = null

@export var player_path: NodePath
@export var damage: int

@onready var nav_agent = $NavigationAgent3D
@onready var animTree = $AnimationTree
@onready var ray_cast_3d: RayCast3D = $Armature/RayCast3D
@onready var vision_area: Area3D = $VisionArea
@onready var vision_raycast: RayCast3D = $vision_raycast
#SFX
@onready var enemyDamage = $enemyDamage


	
const SPEED = 4.0
const ATTACK_RANGE = 1.5

var state
var has_hit_player = false
var can_see = false

func _ready():
	player = get_node(player_path)
	state = animTree.get("parameters/playback")

var can_attack = true
var attack_cooldown = 2.0  # Cooldown in seconds

func _process(_delta: float) -> void:
	velocity = Vector3.ZERO
	
	match state.get_current_node():
		"Run":
			if can_see:
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
				look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			can_attack = true  # Reset attack cooldown when running
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			if ray_cast_3d.is_colliding():
				var collider = ray_cast_3d.get_collider()
				if collider.is_in_group("player") and can_attack:
					collider.take_damage(damage)
					can_attack = false
					await get_tree().create_timer(attack_cooldown).timeout
					can_attack = true
	
	animTree.set("parameters/conditions/attack", _target_in_range())
	animTree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()
	
	
func _target_in_range():
	if animTree.get("parameters/conditions/attack"):
		return global_position.distance_to(player.global_position) < 2 * ATTACK_RANGE
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func take_damage(_dmg):
	enemyDamage.play()
	queue_free()

func _on_vision_timer_timeout() -> void:
	var overlaps = vision_area.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.is_in_group("player"):
				var playerPos = overlap.global_transform.origin
				vision_raycast.look_at(playerPos, Vector3.UP)
				vision_raycast.force_raycast_update()
				if vision_raycast.is_colliding():
					var collider = vision_raycast.get_collider()
					if collider.is_in_group("player"):
						can_see = true
						return
					else:
						can_see = false
	can_see = false

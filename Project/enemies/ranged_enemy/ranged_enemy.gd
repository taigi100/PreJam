extends CharacterBody3D

@export var speed: float = 3.0
@export var attack_range: float = 10.0
@export var attack_cooldown: float = 2.0
@export var attack: AttackResource

@onready var nav_agent = $NavigationAgent3D
@onready var animTree = $AnimationTree
@onready var vision_area: Area3D = $VisionArea
@onready var vision_raycast: RayCast3D = $vision_raycast


var player = null

@export var player_path: NodePath
	
const SPEED = 4.0
const ATTACK_RANGE = 1.5

var state
var has_hit_player = false
var can_see = false
var can_attack = true

func _ready():
	player = get_node(player_path)
	state = animTree.get("parameters/playback")

func _process(delta):
	if player:
		if can_see:
			look_at(player.position, Vector3.UP)
			if global_transform.origin.distance_to(player.global_transform.origin) <= attack_range:
				if can_attack:
					attack.execute(self, player)
					start_attack_cooldown()
			else:
				move_toward_player(delta)

func move_toward_player(delta):
	nav_agent.set_target_position(player.global_transform.origin)
	var direction = (nav_agent.get_next_path_position() - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

func start_attack_cooldown():
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
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

func take_damage(damage):
	queue_free()

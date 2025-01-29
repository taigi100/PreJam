extends CharacterBody3D

@export var speed: float = 3.0
@export var attack_range: float = 10.0
@export var attack_cooldown: float = 2.0
@export var patrol_cooldown: float = 5.0
@export var patrol_radius: float = 50.0
@export var min_patrol: float = 5
@export var health: float = 3.0
@export var attack: AttackResource
@export var player_path: NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var animTree = $AnimationTree
@onready var vision_area: Area3D = $VisionArea
@onready var vision_raycast: RayCast3D = $vision_raycast
@onready var memory_timer: Timer = $MemoryTimer

var player = null
var state
var has_hit_player = false
var can_see = false
var can_attack = true
var memory = false
var is_patrolling = false

func _ready():
	player = get_node(player_path)
	state = animTree.get("parameters/playback")

func _process(delta):
	var will_move = false
	if player:
		if can_see:
			stop_patrol()
			if global_transform.origin.distance_to(player.global_transform.origin) <= attack_range:
				look_at(player.position, Vector3.UP)
				if can_attack:
					attack.execute(self, player)
					start_attack_cooldown()
			else:
				move_toward_player(delta)
				will_move = true
		elif memory:
			stop_patrol()
			move_toward_player(delta)
			will_move = true
		else: # Idle, so patrol
			if !is_patrolling:
				start_patrol()
			if is_patrolling:
				will_move = true
	# Movement
	if will_move:
		var target = nav_agent.get_next_path_position()
		var distance = global_transform.origin.distance_to(target)
		if distance > 1:
			var direction = (target - global_transform.origin).normalized()
			velocity = direction * speed
			look_at(nav_agent.target_position, Vector3.UP)
			move_and_slide()

func start_patrol():
	is_patrolling = true
	_set_random_patrol_point()

func stop_patrol():
	is_patrolling = false

func _set_random_patrol_point():
	var rid = NavigationServer3D.map_get_closest_point_owner(nav_agent.get_navigation_map(), global_position)
	var new_position = NavigationServer3D.region_get_random_point(rid, 1, false)
	nav_agent.target_position = new_position
	await get_tree().create_timer(patrol_cooldown).timeout
	_set_random_patrol_point()

func move_toward_player(delta):
	print("moving towards player")
	nav_agent.set_target_position(player.global_transform.origin)

func start_patrol_cooldown():
	can_attack = false
	await get_tree().create_timer(patrol_cooldown).timeout
	can_attack = true

func start_attack_cooldown():
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func _on_vision_timer_timeout() -> void:
	var overlaps = vision_area.get_overlapping_bodies()
	var found = false
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
						memory = true
						found = true
	if not found:
		can_see = false
		if memory and memory_timer.is_stopped():
			memory_timer.start()

func take_damage(damage):
	health = health - damage
	if health <= 0:
		queue_free()

func _on_memory_timer_timeout() -> void:
	memory = false

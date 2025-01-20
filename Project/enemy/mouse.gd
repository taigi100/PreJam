extends CharacterBody3D


var player = null

@export var player_path: NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var animTree = $AnimationTree

const SPEED = 4.0
const ATTACK_RANGE = 1.5

var state

func _ready():
	player = get_node(player_path)
	state = animTree.get("parameters/playback")

func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	match state.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	print(_target_in_range())
	animTree.set("parameters/conditions/attack", _target_in_range())
	animTree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()
	
	
func _target_in_range():
	if animTree.get("parameters/conditions/attack"):
		return global_position.distance_to(player.global_position) < 2 * ATTACK_RANGE
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

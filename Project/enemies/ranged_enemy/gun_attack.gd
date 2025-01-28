class_name GunAttackResource
extends AttackResource

var bullet = load("res://enemies/common/bullet.tscn")

func execute(enemy: Node3D, target: Node3D):
	print("attacking")
	var instance = bullet.instantiate()
	instance.position = enemy.global_position
	instance.transform.basis = enemy.global_transform.basis
	instance.scale = Vector3(1,1,1)
	enemy.get_parent().add_child(instance)

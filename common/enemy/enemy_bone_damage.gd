extends PhysicalBone3D

@export var damage_multiplier: float = 1.0
signal update_damage

func get_damage(damage:float, direction: Vector3) -> void:
	var final_damage = damage * damage_multiplier
	update_damage.emit(final_damage, direction)

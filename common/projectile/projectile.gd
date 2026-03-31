extends Node3D

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var mesh: Node3D = $mesh
@onready var decal: Node3D = $decal
@onready var sparks: GPUParticles3D = $ElectricSparks_1


const SPEED:float = 60.0
const DAMAGE:float = 20.0
var bullet_hit:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	decal.visible = false

func _physics_process(delta: float) -> void:
	if not ray_cast.is_colliding():
		position += global_transform.basis * Vector3(0,0,-SPEED) * delta
	elif not bullet_hit:
		bullet_impact()
		bullet_hit = true

func bullet_impact() -> void:
	var collider = ray_cast.get_collider()
	if collider and                                           collider.has_method("get_damage"):
		collider.get_damage(DAMAGE, Vector3.UP)
	
	mesh.visible = false
	decal.visible = true
	sparks.emitting = true

	
	await get_tree().create_timer(5.0).timeout
	
	queue_free()

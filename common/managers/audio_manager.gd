extends Node3D

@export var player: CharacterBody3D
@onready var ground_detect_ray_cast: RayCast3D = $GroundDetectRayCast
@onready var footstep_ground: AudioStreamPlayer3D = $FootstepGround
@onready var footstep_jump: AudioStreamPlayer3D = $FootstepJump
@onready var footstep_metal: AudioStreamPlayer3D = $FootstepMetal

var is_on_metal: bool = false

func _ready() -> void:
	# Set up raycast if it exists
	if ground_detect_ray_cast:
		ground_detect_ray_cast.enabled = true
		ground_detect_ray_cast.target_position = Vector3(0, -1.5, 0)  # Cast downward
		ground_detect_ray_cast.collision_mask = 1  # Adjust based on your collision layers


func _physics_process(_delta: float) -> void:
	# Check surface type for footstep sounds
	_check_surface_type()

func _check_surface_type() -> void:
	# Check what surface the player is standing on
	if ground_detect_ray_cast and ground_detect_ray_cast.is_colliding():
		var collider = ground_detect_ray_cast.get_collider()
		if collider and collider.is_in_group("metal"):
			is_on_metal = true
		else:
			is_on_metal = false
	else:
		# Default to ground if no collision detected
		is_on_metal = false

func play_footstep(is_jump: bool) -> void:
	# Play appropriate sound based on context
	if is_jump:
		# Landing sound
		if footstep_jump and not footstep_jump.playing:
			footstep_jump.play()
	else:
		# Regular footstep - check surface type
		if is_on_metal:
			if footstep_metal and not footstep_metal.playing:
				footstep_metal.play()
				footstep_ground.play()
		else:
			if footstep_ground and not footstep_ground.playing:
				footstep_ground.play()

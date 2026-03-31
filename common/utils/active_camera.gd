extends Node3D

# Camera shake
@export var shake_intensity: float = 0.02
@export var shake_duration: float = 0.1
var shake_tween: Tween
var original_camera_rotation: Vector3

# FOV management
const BASE_FOV: float = 75.0
const SPRINT_FOV: float = 85.0
var target_fov: float = BASE_FOV
var is_sprinting: bool = false
var is_aiming: bool = false
var weapon_aim_fov: float = 60.0

@onready var camera_holder: Node3D = $CameraHolder
@onready var main_camera: Camera3D = %MainCamera


func _ready() -> void:
	Global.camera_shake.connect(_on_camera_shake)
	Global.active_camera_fov_changed.connect(_on_weapon_aim_fov_changed)
	Global.player_sprinting_changed.connect(_on_player_sprinting_changed)
	Global.aim_mode_changed.connect(_on_aim_mode_changed)


func _process(delta: float) -> void:
	# Smoothly interpolate camera FOV
	main_camera.fov = lerp(main_camera.fov, target_fov, delta * 10.0)


func _on_weapon_aim_fov_changed(fov_angle: float) -> void:
	# Store weapon aim FOV for when we're in aim mode
	weapon_aim_fov = fov_angle
	_update_target_fov()


func _on_player_sprinting_changed(sprinting: bool) -> void:
	is_sprinting = sprinting
	_update_target_fov()


func _on_aim_mode_changed(aim_mode: bool) -> void:
	is_aiming = aim_mode
	_update_target_fov()


func _update_target_fov() -> void:
	# Priority: Aim mode > Sprint > Base
	if is_aiming:
		target_fov = weapon_aim_fov
	elif is_sprinting:
		target_fov = SPRINT_FOV
	else:
		target_fov = BASE_FOV


func _on_camera_shake() -> void:
	# Kill existing shake tween if running
	if shake_tween:
		shake_tween.kill()
	
	# Store original rotation
	original_camera_rotation = camera_holder.rotation
	
	# Apply random shake offset
	var shake_offset = Vector3(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	
	camera_holder.rotation = original_camera_rotation + shake_offset
	
	# Tween back to original rotation
	shake_tween = create_tween()
	shake_tween.tween_property(camera_holder, "rotation", original_camera_rotation, shake_duration)

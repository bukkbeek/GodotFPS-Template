extends Node3D

@export_group("weapon settings")
@export var is_melee_weapon: bool = false

#NOTE: projectiles work independetly/ see below for node paths
@export var is_projectile: bool = false
@export var firing_distance: float = 20.0

@export var fps_arms_root:Node3D

@export var animation_player:AnimationPlayer
@export var animation_fire:String = "_fire"
@export var animation_reload:String = "_reload"

@export_group("bullets")
@export var bullet_type: Bullets.AmmoType = Bullets.AmmoType.PISTOL
@export var damage: float = 100.0
@export var cooldown: float = 1.0 #cooldown between shots
@export var burst_mode:bool = false
@export var consume:int = 1 #bullet use per firing (shotguns > 1)
@export var reload_required:bool = true
@export var mag_capacity: int = 30
@export var reload_time: float = 1.5

@export_group("gameplay connections")
@export var focused_aim_fov:float = 60.0

@export var focused_aim_angle:float = 0.0
@export var standard_aim_angle:float = 2.0

# Aim transition settings
const AIM_TRANSITION_DURATION: float = 0.2

@export_group("sfx")
@export var firing_sfx:AudioStreamPlayer3D
@export var reload_sfx:AudioStreamPlayer3D
@export var empty_mag_sfx:AudioStreamPlayer3D

@export_group("vfx")
@export var firing_vfx:PackedScene
@export var muzzle_flash_position: Marker3D
@export var bullet_decal:PackedScene

@onready var standard_aim_position: Marker3D = $StandardAimPosition
@onready var focused_aim_position: Marker3D = $FocusedAimPosition

#INFO: PROJECTILES

var is_aimed: bool = false

# Weapon state variables
var can_fire: bool = true
var is_reloading: bool = false
var current_mag: int = 0
var played_empty_sound_this_press: bool = false

# References
var main_camera: Camera3D
var weapon_ray_cast: RayCast3D
var ray_cast_origin: Node3D

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var reload_timer: Timer = $ReloadTimer


# Aim transition tween
var aim_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.aim_mode_changed.connect(_on_aim_mode_changed)
	$TestCamera.visible = false
	$TestTarget.visible = false
	
	# Initialize magazine
	current_mag = mag_capacity

func initialize(camera: Camera3D, raycast: RayCast3D, raycast_origin: Node3D) -> void:
	main_camera = camera
	weapon_ray_cast = raycast
	ray_cast_origin = raycast_origin

func activate(current_aim_mode: bool = false) -> void:
	visible = true
	can_fire = true
	is_reloading = false
	
	# Kill any lingering aim tween so the position snap below is never overridden
	if aim_tween:
		aim_tween.kill()
		aim_tween = null
	
	# Update raycast distance for this weapon
	if weapon_ray_cast:
		weapon_ray_cast.target_position = Vector3(0, 0, -firing_distance)
	
	# Snap to the correct aim position for this weapon
	is_aimed = current_aim_mode
	if fps_arms_root:
		if is_aimed:
			fps_arms_root.transform = focused_aim_position.transform
		else:
			fps_arms_root.transform = standard_aim_position.transform
	
	# Emit FOV only if weapon is activated while aiming
	if is_aimed:
		Global.active_camera_fov_changed.emit(focused_aim_fov)

func deactivate() -> void:
	visible = false

func try_fire(is_initial_press: bool = false) -> bool:
	# Reset empty sound flag on initial press
	if is_initial_press:
		played_empty_sound_this_press = false
	
	if not can_fire or is_reloading:
		return false
	
	# Melee weapons skip all ammo and reload checks
	if not is_melee_weapon:
		# Check if reload is needed
		if reload_required and current_mag < consume:
			start_reload()
			# Play empty mag sound only once per press
			if empty_mag_sfx and not played_empty_sound_this_press:
				empty_mag_sfx.play()
				played_empty_sound_this_press = true
			return false
		
		# Check ammo in inventory
		if not Bullets._consume_ammo(bullet_type, 0):  # Just check, don't consume yet
			if empty_mag_sfx and not played_empty_sound_this_press:
				empty_mag_sfx.play()
				played_empty_sound_this_press = true
			return false
	
	fire_weapon()
	return true

func fire_weapon() -> void:
	# Consume ammo from magazine or inventory (melee skips this entirely)
	if not is_melee_weapon:
		if reload_required:
			current_mag -= consume
		else:
			if not Bullets._consume_ammo(bullet_type, consume):
				return
		Global.bullets_changed.emit()
	
	# Play fire animation
	if animation_player and animation_fire:
		animation_player.play(animation_fire)
	
	# Play fire SFX
	if firing_sfx:
		firing_sfx.play()
	
	# Muzzle flash VFX (ranged weapons only)
	if not is_melee_weapon and firing_vfx and muzzle_flash_position:
		var muzzle_instance = firing_vfx.instantiate()
		muzzle_flash_position.add_child(muzzle_instance)

	# Perform raycast hit detection
	if weapon_ray_cast and ray_cast_origin:
		# Apply recoil/spread rotation
		var recoil_angle = focused_aim_angle if is_aimed else standard_aim_angle
		ray_cast_origin.rotation_degrees = Vector3(
			randf_range(-recoil_angle, recoil_angle),
			randf_range(-recoil_angle, recoil_angle),
			0
		)
		
		weapon_ray_cast.force_raycast_update()
		
		# Reset rotation
		ray_cast_origin.rotation = Vector3.ZERO
		
		if weapon_ray_cast.is_colliding():
			var collider = weapon_ray_cast.get_collider()
			var hit_point = weapon_ray_cast.get_collision_point()
			var hit_normal = weapon_ray_cast.get_collision_normal()
			
			# Bullet decal (ranged weapons only)
			if not is_melee_weapon and bullet_decal:
				var decal_instance = bullet_decal.instantiate()
				get_tree().root.add_child(decal_instance)
				decal_instance.global_position = hit_point
				# Use a different up vector if hit normal is nearly vertical to avoid colinear vectors
				var up_vector = Vector3.UP
				if abs(hit_normal.dot(Vector3.UP)) > 0.99:
					up_vector = Vector3.FORWARD
				decal_instance.look_at(hit_point + hit_normal, up_vector)
			
			# Check if collider can take damage
			if collider and collider.has_method("get_damage"):
				var direction = (hit_point - global_position).normalized()
				collider.get_damage(damage, direction)
	
	# Start cooldown
	can_fire = false
	cooldown_timer.start(cooldown)
	
	# Camera shake
	Global.camera_shake.emit()

func start_reload() -> void:
	if is_reloading or not reload_required:
		return
	
	# Check if we have ammo to reload
	var available_ammo = Bullets._get_ammo(bullet_type)
	if available_ammo <= 0 and available_ammo != -1:  # -1 is infinite
		return
	
	is_reloading = true
	
	# Play reload animation
	if animation_player and animation_reload:
		animation_player.play(animation_reload)
	
	# Play reload SFX
	if reload_sfx:
		reload_sfx.play()
	
	# Start reload timer
	reload_timer.start(reload_time)

func _on_cooldown_timer_timeout() -> void:
	can_fire = true

func _on_reload_timer_timeout() -> void:
	is_reloading = false
	
	# Calculate ammo needed
	var ammo_needed = mag_capacity - current_mag
	var available_ammo = Bullets._get_ammo(bullet_type)
	
	# Handle infinite ammo
	if available_ammo == -1:
		current_mag = mag_capacity
	else:
		var ammo_to_load = min(ammo_needed, available_ammo)
		Bullets._consume_ammo(bullet_type, ammo_to_load)
		current_mag += ammo_to_load
	
	Global.bullets_changed.emit()

func get_current_mag() -> int:
	if is_melee_weapon:
		return -1
	return current_mag

func get_current_ammo() -> int:
	if is_melee_weapon:
		return -1
	return Bullets._get_ammo(bullet_type)

func get_max_ammo() -> int:
	if is_melee_weapon:
		return -1
	return Bullets._get_max_ammo(bullet_type)

func _on_aim_mode_changed(aim_mode:bool) -> void:
	# Only respond to aim changes if this weapon is currently active
	if not visible:
		return
	
	is_aimed = aim_mode
	
	# Kill any existing aim tween to prevent conflicts
	if aim_tween:
		aim_tween.kill()
	
	if fps_arms_root:
		# Create a new tween for smooth transition
		aim_tween = create_tween()
		aim_tween.set_parallel(true)
		aim_tween.set_ease(Tween.EASE_IN_OUT)
		aim_tween.set_trans(Tween.TRANS_CUBIC)
		
		# Tween to the target position
		var target_transform = focused_aim_position.transform if aim_mode else standard_aim_position.transform
		aim_tween.tween_property(fps_arms_root, "transform", target_transform, AIM_TRANSITION_DURATION)
	
	# Emit FOV change only when entering aim mode
	if aim_mode:
		Global.active_camera_fov_changed.emit(focused_aim_fov)
		if Global.debug_mode:
			print("AIM MODE: ", aim_mode, " - Weapon: ", name, " - FOV: ", focused_aim_fov)

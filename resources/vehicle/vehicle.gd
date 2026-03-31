extends VehicleBody3D

var player_in_range: bool = false
var is_driving: bool = false

@export_group("Visuals")
@export var door_mesh: Node3D
@export var door_outline_mesh: Node3D
@export var vehicle_outline_mesh: Node3D
@export var animation_player: AnimationPlayer
@export var get_in_animation: StringName = &"get_in"

@export_group("Engine")
@export var engine_force_value: float = 80.0
@export var max_rpm: float = 200.0
@export var brake_strength: float = 10.0

@export_group("Steering")
@export var steering_limit: float = 0.4
@export var steering_speed: float = 3.0

@export_group("Camera")
@export var camera_sensitivity: float = 0.003
@export var camera_pitch_min: float = -40.0
@export var camera_pitch_max: float = 60.0

@export_group("Audio")
@export var engine_audio: AudioStreamPlayer3D
@export var engine_min_pitch: float = 0.6
@export var engine_max_pitch: float = 2.2
## Speed in m/s at which pitch reaches its maximum.
@export var engine_max_speed: float = 28.0

@onready var camera: Camera3D = $Camera3D
@onready var player_exit: Marker3D = $PlayerExit


var _steering_input: float = 0.0
var _cam_yaw: float = 0.0
var _cam_pitch: float = 0.0

@export var damage: float = 50.0

func _ready() -> void:
	camera.current = false
	Global.activate_pressed.connect(_on_activate_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not is_driving:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_cam_yaw -= event.relative.x * camera_sensitivity
		_cam_pitch -= event.relative.y * camera_sensitivity
		_cam_pitch = clamp(_cam_pitch, deg_to_rad(camera_pitch_min), deg_to_rad(camera_pitch_max))


func _process(delta: float) -> void:
	if not is_driving:
		return

	# --- Free-look camera (independent of vehicle body) ---
	camera.rotation = Vector3(_cam_pitch, _cam_yaw, 0.0)

	# --- Driving inputs ---
	var throttle := Input.is_action_pressed("forward")
	var reverse := Input.is_action_pressed("backward")
	var turn_left := Input.is_action_pressed("left")
	var turn_right := Input.is_action_pressed("right")
	var braking := Input.is_action_pressed("brake")

	if throttle:
		engine_force = engine_force_value
	elif reverse:
		engine_force = -engine_force_value
	else:
		engine_force = 0.0

	brake = brake_strength if braking else 0.0

	var target_steer := 0.0
	if turn_left:
		target_steer = steering_limit
	elif turn_right:
		target_steer = -steering_limit

	_steering_input = lerp(_steering_input, target_steer, steering_speed * delta)
	steering = _steering_input

	# --- Engine audio pitch based on speed ---
	_update_engine_audio()


func _on_activate_pressed() -> void:
	if is_driving:
		_exit_vehicle()
	elif player_in_range:
		_enter_vehicle()


func _enter_vehicle() -> void:
	var player := Global.player
	if not player:
		return

	is_driving = true
	Global.in_vehicle = true

	# Align free-look yaw to the vehicle's current world yaw so the view
	# doesn't snap when entering.
	_cam_yaw = 0.0
	_cam_pitch = 0.0

	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.visible = false

	camera.make_current()

	engine_force = 0.0
	brake = 0.0
	_steering_input = 0.0
	steering = 0.0

	if engine_audio:
		engine_audio.pitch_scale = engine_min_pitch
		engine_audio.play()

	if door_mesh:
		door_mesh.visible = true

	if animation_player and get_in_animation:
		animation_player.play(get_in_animation)

	_update_outline()


func _exit_vehicle() -> void:
	var player := Global.player
	if not player:
		return

	is_driving = false
	Global.in_vehicle = false

	player.global_position = player_exit.global_position

	player.visible = true
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)

	player.camera.make_current()

	engine_force = 0.0
	brake = brake_strength
	_steering_input = 0.0
	steering = 0.0

	if engine_audio:
		engine_audio.stop()

	_update_outline()


func _update_engine_audio() -> void:
	if not engine_audio:
		return
	var speed := linear_velocity.length()
	var t := clampf(speed / engine_max_speed, 0.0, 1.0)
	engine_audio.pitch_scale = lerp(engine_min_pitch, engine_max_pitch, t)


func _update_outline() -> void:
	var show := player_in_range and not is_driving
	if vehicle_outline_mesh:
		vehicle_outline_mesh.visible = show
	if door_outline_mesh:
		door_outline_mesh.visible = show


func _on_door_area_3d_body_entered(body: Node3D) -> void:
	if body and body.is_in_group("player"):
		player_in_range = true
		_update_outline()


func _on_door_area_3d_body_exited(body: Node3D) -> void:
	if body and body.is_in_group("player"):
		player_in_range = false
		_update_outline()


func _on_bumper_body_entered(body: Node3D) -> void:
	if Global.in_vehicle and body and body.has_method("get_damage"):
		var direction = global_position.direction_to(body.global_position)
		body.get_damage(damage, direction)

extends Control

# Dynamic crosshair elements
@onready var crosshair_top: ColorRect = $CrosshairTop
@onready var crosshair_bottom: ColorRect = $CrosshairBottom
@onready var crosshair_left: ColorRect = $CrosshairLeft
@onready var crosshair_right: ColorRect = $CrosshairRight
@onready var crosshair_center: ColorRect = $CrosshairCenter


# Crosshair settings
const LINE_WIDTH: float = 3.0
const LINE_LENGTH: float = 10.0
const CENTER_DOT_SIZE: float = 2.0

const MIN_SPREAD: float = 10.0  # Minimum distance from center when aiming
const MAX_SPREAD: float = 50.0  # Maximum distance from center when moving fast
const BASE_SPREAD: float = 25.0  # Default spread

var current_spread: float = BASE_SPREAD
var target_spread: float = BASE_SPREAD
var is_aiming: bool = false



func _ready() -> void:
	Global.aim_mode_changed.connect(_on_aim_mode_changed)
	Global.player_velocity_changed.connect(_on_player_velocity_changed)
	_setup_crosshair()

func _setup_crosshair() -> void:
	# Setup is now handled by the scene, but we update positions
	_update_crosshair_positions()

func _process(delta: float) -> void:
	# Smoothly interpolate to target spread
	current_spread = lerp(current_spread, target_spread, delta * 10.0)
	_update_crosshair_positions()


func _on_player_velocity_changed(velocity: Vector3) -> void:
	if is_aiming:
		return
	
	# Calculate horizontal velocity magnitude
	var horizontal_velocity = Vector2(velocity.x, velocity.z).length()
	
	# Map velocity to spread (0-10 units -> BASE to MAX spread)
	var velocity_factor = clamp(horizontal_velocity / 10.0, 0.0, 1.0)
	target_spread = lerp(BASE_SPREAD, MAX_SPREAD, velocity_factor)


func _update_crosshair_positions() -> void:
	var center_x = size.x / 2.0
	var center_y = size.y / 2.0
	
	# Top line
	crosshair_top.position = Vector2(center_x - LINE_WIDTH / 2.0, center_y - current_spread - LINE_LENGTH)
	crosshair_top.size = Vector2(LINE_WIDTH, LINE_LENGTH)
	
	# Bottom line
	crosshair_bottom.position = Vector2(center_x - LINE_WIDTH / 2.0, center_y + current_spread)
	crosshair_bottom.size = Vector2(LINE_WIDTH, LINE_LENGTH)
	
	# Left line
	crosshair_left.position = Vector2(center_x - current_spread - LINE_LENGTH, center_y - LINE_WIDTH / 2.0)
	crosshair_left.size = Vector2(LINE_LENGTH, LINE_WIDTH)
	
	# Right line
	crosshair_right.position = Vector2(center_x + current_spread, center_y - LINE_WIDTH / 2.0)
	crosshair_right.size = Vector2(LINE_LENGTH, LINE_WIDTH)
	
	# Center dot
	crosshair_center.position = Vector2(center_x - CENTER_DOT_SIZE / 2.0, center_y - CENTER_DOT_SIZE / 2.0)
	crosshair_center.size = Vector2(CENTER_DOT_SIZE, CENTER_DOT_SIZE)

func _on_aim_mode_changed(aim_mode: bool) -> void:
	is_aiming = aim_mode
	if aim_mode:
		# Hide crosshair when aiming down sights
		crosshair_top.visible = false
		crosshair_bottom.visible = false
		crosshair_left.visible = false
		crosshair_right.visible = false
		crosshair_center.visible = false
	else:
		crosshair_top.visible = true
		crosshair_bottom.visible = true
		crosshair_left.visible = true
		crosshair_right.visible = true
		crosshair_center.visible = true

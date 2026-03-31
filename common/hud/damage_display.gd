extends Control

const DAMGE_COLOR:= Color(0.5,0,0,0.5)
const HEAL_COLOR:= Color(0,0.5,0,0.5)

@onready var claw_rect: TextureRect = $ClawRect
@onready var damage_overlay: ColorRect = $DamageOverlay

var claw_rect_current_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	claw_rect.visible = false
	damage_overlay.visible = false
	claw_rect_current_pos = position
	Global.player_health_changed.connect(_on_player_health_changed)



func _on_player_health_changed(health_change:float,_current_health:float,_max_health:float, is_enemy_damage:bool) -> void:
	if health_change < 0:
		
		# Only show claw marks for enemy damage
		if is_enemy_damage:
			# Random rotation for scratch mark effect (full 360 degrees)
			claw_rect.rotation_degrees = randf_range(0, 360)
			
			# Random offset from center (15-40 pixels in any direction)
			var random_offset_x = randf_range(-40, 40)
			var random_offset_y = randf_range(-40, 40)
			
			# Ensure offset is at least 15 pixels from center
			var min_offset = 15.0
			if abs(random_offset_x) < min_offset:
				random_offset_x = min_offset if random_offset_x >= 0 else -min_offset
			if abs(random_offset_y) < min_offset:
				random_offset_y = min_offset if random_offset_y >= 0 else -min_offset
			
			# Position around center with random offset
			var center_x = size.x / 2.0
			var center_y = size.y / 2.0
			claw_rect.position = Vector2(center_x + random_offset_x, center_y + random_offset_y)
			
			# Random scale for varied scratch marks (0.7-1.5 for more variation)
			claw_rect.scale.x = randf_range(0.7, 1.5)
			claw_rect.scale.y = randf_range(0.7, 1.5)
			
			claw_rect.visible = true
		
		damage_overlay.visible = true
		
		await get_tree().create_timer(0.2).timeout
		damage_overlay.modulate.a = 0.75
		
		await get_tree().create_timer(0.2).timeout
		damage_overlay.modulate.a = 0.50
		
		await get_tree().create_timer(0.2).timeout
		damage_overlay.modulate.a = 0.25
		
		await get_tree().create_timer(0.2).timeout
		damage_overlay.modulate.a = 0.00
		
		
		await get_tree().create_timer(1.6).timeout
		
		claw_rect.visible = false
		damage_overlay.visible = false

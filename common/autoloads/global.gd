extends Node

var debug_mode: bool = false
var player: CharacterBody3D
var enemies_killed: int = 0
var in_vehicle: bool = false

@warning_ignore("unused_signal")
signal enemy_killed

@warning_ignore("unused_signal")
signal enemy_count_changed(count: int)


@warning_ignore("unused_signal")
signal aim_mode_changed

@warning_ignore("unused_signal")
signal active_camera_fov_changed

@warning_ignore("unused_signal")
signal fire_input

@warning_ignore("unused_signal")
signal reload_input

@warning_ignore("unused_signal")
signal weapon_switch_next

@warning_ignore("unused_signal")
signal weapon_switch_prev

@warning_ignore("unused_signal")
signal bullets_changed

@warning_ignore("unused_signal")
signal camera_shake

@warning_ignore("unused_signal")
signal player_velocity_changed

@warning_ignore("unused_signal")
signal player_health_changed(health_change: float, current_health: float, max_health: float, is_enemy_damage: bool)

@warning_ignore("unused_signal")
signal player_dead

@warning_ignore("unused_signal")
signal player_sprinting_changed

@warning_ignore("unused_signal")
signal activate_pressed


func _ready() -> void:
	enemy_killed.connect(_on_enemy_killed)


func _on_enemy_killed() -> void:
	enemies_killed += 1
	enemy_count_changed.emit(enemies_killed)

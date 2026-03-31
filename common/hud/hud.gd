extends Control

@onready var enemies_label: Label = $EnemiesLabel
@onready var bullets_label: Label = $BulletsLabel
@onready var health_bar: ProgressBar = $HealthBar

var weapons_manager = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.bullets_changed.connect(_on_bullets_changed)
	Global.player_health_changed.connect(_on_player_health_changed)
	Global.enemy_count_changed.connect(_on_enemy_count_changed)
	
	# Get weapons manager from player
	if Global.player:
		weapons_manager = Global.player.get_node_or_null("WeaponsManager")
	
	# Initial display updates
	_on_bullets_changed()
	_on_enemy_count_changed(Global.enemies_killed)


func _on_bullets_changed() -> void:
	if not weapons_manager or not weapons_manager.current_weapon:
		bullets_label.text = "AMMO: --/--"
		return
	
	var current_mag = weapons_manager.get_current_mag()
	var current_ammo = weapons_manager.get_current_ammo()
	
	# Handle infinite ammo display (-1)
	if current_ammo == -1:
		if weapons_manager.current_weapon.reload_required:
			bullets_label.text = str("AMMO: ", current_mag, "/∞")
		else:
			bullets_label.text = "AMMO: ∞"
	else:
		if weapons_manager.current_weapon.reload_required:
			bullets_label.text = str("AMMO: ", current_mag, "/", current_ammo)
		else:
			bullets_label.text = str("AMMO: ", current_ammo)


func _on_enemy_count_changed(count: int) -> void:
	enemies_label.text = str("ENEMIES KILLED: ", count)


func _on_player_health_changed(_health_change:float,current_health:float,max_health:float, _is_enemy_damage:bool) -> void:
	update_health_bar(current_health,max_health)
		

func update_health_bar(current_health,max_health) -> void:
	health_bar.value = current_health
	health_bar.max_value = max_health

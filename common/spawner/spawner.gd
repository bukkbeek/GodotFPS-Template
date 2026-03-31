extends Node3D
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var spawn_timer: Timer = $SpawnTimer

@export var item:PackedScene
@export var wait_time: float = 2.0
@export var spawn_time: float = 5.0
@export var time_increment: float = 0.1
@export var max_spawn_time: float = 10.0
@export var min_spawn_time: float = 10.0
@export var max_items: int = 1
@export var spawn_range: float = 2.0

var current_item_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.start(wait_time)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)



func _on_spawn_timer_timeout() -> void:
	if spawn_time <= max_spawn_time and spawn_time >= min_spawn_time:
		spawn_time -= time_increment
	spawn_timer.start(spawn_time)
	
	# Only spawn if below max items limit
	if current_item_count >= max_items:
		return
	
	var instance = item.instantiate()
	
	# Calculate spawn position with random offset on x and z plane
	var random_offset = Vector3(
		randf_range(-spawn_range, spawn_range),
		0.0,
		randf_range(-spawn_range, spawn_range)
	)
	var spawn_position = global_position + random_offset
	
	# Track when the item is removed from the scene
	instance.tree_exited.connect(_on_item_removed)
	current_item_count += 1
	
	get_parent().add_child.call_deferred(instance)
	instance.set_deferred("global_position", spawn_position)


func _on_item_removed() -> void:
	current_item_count -= 1

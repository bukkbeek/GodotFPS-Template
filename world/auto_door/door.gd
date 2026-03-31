extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	close_door()

func open_door() -> void:
	animation_player.play("door_open")
	$DoorSFX.play()

func close_door() -> void:
	animation_player.play("door_close")
	$DoorSFX.play()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("door_access"):
		open_door()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("door_access"):
		close_door()

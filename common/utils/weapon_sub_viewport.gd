extends SubViewport

@onready var camera: Camera3D = $Camera3D
@onready var main_camera: Camera3D = %MainCamera

func _process(_delta: float) -> void:
	camera.global_transform = main_camera.global_transform

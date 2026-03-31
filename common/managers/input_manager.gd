extends Node

var aim_mode:bool = false
var mouse_mode_captured:bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	#AIM_MODE
	if event.is_action_pressed("aim_mode"):
		aim_mode = true
		Global.aim_mode_changed.emit(aim_mode)
	elif event.is_action_released("aim_mode"):
		aim_mode = false
		Global.aim_mode_changed.emit(aim_mode)


func _process(_delta: float) -> void:
	if not Global.in_vehicle:
		#FIRING
		if Input.is_action_just_pressed("fire"):
			Global.fire_input.emit()

		#RELOAD
		if Input.is_action_just_pressed("reload"):
			Global.reload_input.emit()

		#WEAPON SWITCHING
		if Input.is_action_just_pressed("weapon_change_next"):
			Global.weapon_switch_next.emit()

		if Input.is_action_just_pressed("weapon_change_prev"):
			Global.weapon_switch_prev.emit()

	#ACTIVATE
	if Input.is_action_just_pressed("activate"):
		Global.activate_pressed.emit()

	#MOUSE_MODE
	if Input.is_action_just_pressed("exit"):
		mouse_mode_captured = !mouse_mode_captured
		if mouse_mode_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

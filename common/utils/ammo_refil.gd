extends Area3D
@export var outline_mesh:Node3D

@export_group("Ammo Stock")
@export var pistol_ammo: int = 999
@export var smg_ammo: int = 999
@export var assault_ammo: int = 999
@export var shotgun_ammo: int = 999
@export var lmg_ammo: int = 999
@export var sniper_ammo: int = 999
@export var hand_grenade_ammo: int = 999
@export var smoke_grenade_ammo: int = 999
@export var rocket_ammo: int = 999
@export var fuel_ammo: int = 999
@export var plasma_ammo: int = 999

var player_in_range: bool = false
var is_depleted: bool = false



func _ready() -> void:
	if outline_mesh:
		outline_mesh.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if is_depleted or not player_in_range or Global.in_vehicle:
		return
	if event.is_action_pressed("activate"):
		_refill_player()


func _refill_player() -> void:
	var gave_any: bool = false

	var refill_map: Array = [
		[Bullets.AmmoType.PISTOL,        pistol_ammo],
		[Bullets.AmmoType.SMG,           smg_ammo],
		[Bullets.AmmoType.ASSAULT,       assault_ammo],
		[Bullets.AmmoType.SHOTGUN,       shotgun_ammo],
		[Bullets.AmmoType.LMG,           lmg_ammo],
		[Bullets.AmmoType.SNIPER,        sniper_ammo],
		[Bullets.AmmoType.HAND_GRENADE,  hand_grenade_ammo],
		[Bullets.AmmoType.SMOKE_GRENADE, smoke_grenade_ammo],
		[Bullets.AmmoType.ROCKET,        rocket_ammo],
		[Bullets.AmmoType.FUEL,          fuel_ammo],
		[Bullets.AmmoType.PLASMA,        plasma_ammo],
	]

	for entry in refill_map:
		var ammo_type: Bullets.AmmoType = entry[0]
		var stock: int = entry[1]
		if stock <= 0:
			continue

		var before: int = Bullets._get_ammo(ammo_type)
		var max_ammo: int = Bullets._get_max_ammo(ammo_type)
		if before == -1 or before >= max_ammo:
			continue

		var can_give: int = min(stock, max_ammo - before)
		Bullets._add_ammo(ammo_type, can_give)
		_drain_stock(entry, can_give)
		gave_any = true

	if gave_any:
		Global.bullets_changed.emit()
		_check_depleted()


func _drain_stock(entry: Array, amount: int) -> void:
	match entry[0]:
		Bullets.AmmoType.PISTOL:        pistol_ammo        -= amount
		Bullets.AmmoType.SMG:           smg_ammo           -= amount
		Bullets.AmmoType.ASSAULT:       assault_ammo       -= amount
		Bullets.AmmoType.SHOTGUN:       shotgun_ammo       -= amount
		Bullets.AmmoType.LMG:           lmg_ammo           -= amount
		Bullets.AmmoType.SNIPER:        sniper_ammo        -= amount
		Bullets.AmmoType.HAND_GRENADE:  hand_grenade_ammo  -= amount
		Bullets.AmmoType.SMOKE_GRENADE: smoke_grenade_ammo -= amount
		Bullets.AmmoType.ROCKET:        rocket_ammo        -= amount
		Bullets.AmmoType.FUEL:          fuel_ammo          -= amount
		Bullets.AmmoType.PLASMA:        plasma_ammo        -= amount


func _check_depleted() -> void:
	var total: int = (pistol_ammo + smg_ammo + assault_ammo + shotgun_ammo +
		lmg_ammo + sniper_ammo + hand_grenade_ammo + smoke_grenade_ammo +
		rocket_ammo + fuel_ammo + plasma_ammo)
	if total <= 0:
		is_depleted = true


func _on_body_entered(body: Node3D) -> void:
	if body and body.is_in_group("player"):
		player_in_range = true
		if outline_mesh:
			outline_mesh.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body and body.is_in_group("player"):
		player_in_range = false
		if outline_mesh:
			outline_mesh.visible = false

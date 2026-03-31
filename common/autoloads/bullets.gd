extends Node

# Enum for bullet types that can be selected in weapons
enum AmmoType {
	KNIFE,
	PISTOL,
	SMG,
	ASSAULT,
	SHOTGUN,
	LMG,
	SNIPER,
	HAND_GRENADE,
	SMOKE_GRENADE,
	ROCKET,
	FUEL,
	PLASMA
}

# Dictionary to store ammo counts for each type
var ammo_inventory: Dictionary = {
	AmmoType.KNIFE: {
		"current": -1,  # Infinite ammo for melee
		"max": -1
	},
	AmmoType.PISTOL: {
		"current": 60,
		"max": 120
	},
	AmmoType.SMG: {
		"current": 150,
		"max": 300
	},
	AmmoType.ASSAULT: {
		"current": 480,
		"max": 480
	},
	AmmoType.SHOTGUN: {
		"current": 20,
		"max": 40
	},
	AmmoType.LMG: {
		"current": 100,
		"max": 400
	},
	AmmoType.SNIPER: {
		"current": 10,
		"max": 30
	},
	AmmoType.HAND_GRENADE: {
		"current": 3,
		"max": 10
	},
	AmmoType.SMOKE_GRENADE: {
		"current": 2,
		"max": 8
	},
	AmmoType.ROCKET: {
		"current": 2,
		"max": 4
	},
	AmmoType.FUEL: {
		"current": 200,
		"max": 400
	},
	AmmoType.PLASMA: {
		"current": 50,
		"max": 150
	}
}

# Helper function to get current ammo for a type
func _get_ammo(type: AmmoType) -> int:
	if type in ammo_inventory:
		return ammo_inventory[type]["current"]
	return 0

# Helper function to get max ammo for a type
func _get_max_ammo(type: AmmoType) -> int:
	if type in ammo_inventory:
		return ammo_inventory[type]["max"]
	return 0

# Helper function to add ammo
func _add_ammo(type: AmmoType, amount: int) -> void:
	if type in ammo_inventory:
		# Don't add to infinite ammo types
		if ammo_inventory[type]["current"] == -1:
			return
		ammo_inventory[type]["current"] = min(
			ammo_inventory[type]["current"] + amount,
			ammo_inventory[type]["max"]
		)

# Helper function to consume ammo
func _consume_ammo(type: AmmoType, amount: int) -> bool:
	if type in ammo_inventory:
		# Infinite ammo check (value -1)
		if ammo_inventory[type]["current"] == -1:
			return true
		# Regular ammo check
		if ammo_inventory[type]["current"] >= amount:
			ammo_inventory[type]["current"] -= amount
			return true
	return false

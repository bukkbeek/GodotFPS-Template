extends Node3D

@onready var fire: GPUParticles3D = $Fire
@onready var sparks: GPUParticles3D = $Sparks
@onready var smoke: GPUParticles3D = $Smoke
@onready var debri: GPUParticles3D = $Debri
@onready var debri_pile: GPUParticles3D = $DebriPile


# Called when the node enters the scene tree for the first time.
func activate() -> void:
	fire.emitting = true
	sparks.emitting = true
	smoke.emitting = true
	debri.emitting = true
	debri_pile.emitting = true

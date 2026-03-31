extends Node3D

@onready var omni_light: OmniLight3D = $OmniLight3D
@onready var fire: GPUParticles3D = $Fire
@onready var sparks: GPUParticles3D = $Sparks
@onready var smoke: GPUParticles3D = $Smoke
@onready var debri: GPUParticles3D = $Debri
@onready var debri_smoke: GPUParticles3D = $DebriSmoke
@onready var explosion_sfx: AudioStreamPlayer3D = $ExplosionSFX

func activate() -> void:
	omni_light.visible = true
	fire.restart()
	sparks.restart()
	smoke.restart()
	debri.restart()
	explosion_sfx.play()
	
	await get_tree().create_timer(0.1).timeout
	omni_light.visible = false

extends Node2D

class_name Hazard

@export var damage: float

func _ready() -> void:
	self.add_to_group("Hazards")
	
func DamagePlayer(player) -> void:
	player.battery -= damage
	PlayAudio()
	
func PlayAudio() -> void:
	self.find_child("AudioStreamPlayer").play()

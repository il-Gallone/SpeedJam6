extends Node2D

@export var damage: float

func _ready() -> void:
	self.add_to_group("Hazards")
	
func DamagePlayer(player) -> void:
	player.battery -= damage

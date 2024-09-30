extends "res://Scripts/CollectableBase.gd"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgradeAmount = 200
	type = upgradeType.REFILL
	self.add_to_group("Refills")
	
func Respawn() -> void:
	show()
	$CollisionShape2D.disabled = false
	

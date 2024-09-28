extends "res://Scripts/CollectableBase.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = upgradeType.PRIME
	
func PrimeUpgrade(player):
	player.maxJumpsAvailable += 1
	if player.maxJumpsAvailable == 2:
		DisplayDoubleJumpTutorial()
	
func DisplayDoubleJumpTutorial():
	#TODO: Add Double Jump Tutorial
	pass

extends "res://Scripts/CollectableBase.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = upgradeType.PRIME
	
func PrimeUpgrade(player):
	player.dashesAvailable = true
	DisplayDashTutorial()
	
func DisplayDashTutorial():
	#TODO: Add Dash Tutorial
	pass

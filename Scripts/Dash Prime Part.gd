extends "res://Scripts/CollectableBase.gd"

const dashTut = preload("res://Prefabs/UI/DashTut.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = upgradeType.PRIME
	
func PrimeUpgrade(player):
	player.dashesAvailable = true
	DisplayDashTutorial()
	
func DisplayDashTutorial():
	var tut = dashTut.instantiate()
	tut.position = position - Vector2(0, 100)
	get_tree().current_scene.add_child(tut)

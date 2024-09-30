extends "res://Scripts/CollectableBase.gd"


const grappleTut = preload("res://Prefabs/UI/GrappleTut.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = upgradeType.PRIME
	
func PrimeUpgrade(player):
	player.isHookReady = true
	DisplayGrappleTutorial()
	
func DisplayGrappleTutorial():
	var tut = grappleTut.instantiate()
	tut.position = position - Vector2(0, 100)
	get_tree().current_scene.add_child(tut)

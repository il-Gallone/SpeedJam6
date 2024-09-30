extends "res://Scripts/CollectableBase.gd"

const jumpTut = preload("res://Prefabs/UI/AirJumpTut.tscn")
const airJumpPrompt = preload("res://Prefabs/UI/AirJumpPrompt.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = upgradeType.PRIME
	
func PrimeUpgrade(player):
	player.maxJumpsAvailable += 1
	if player.maxJumpsAvailable == 2:
		DisplayDoubleJumpTutorial()
	else:
		DisplayAirJumpPrompt()
	
func DisplayDoubleJumpTutorial():
	var tut = jumpTut.instantiate()
	tut.position = position - Vector2(0, 300)
	get_tree().current_scene.add_child(tut)
	
func DisplayAirJumpPrompt():
	var prompt = airJumpPrompt.instantiate()
	prompt.position = position - Vector2(0, 100)
	get_tree().current_scene.add_child(prompt)

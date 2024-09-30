extends CollectableBase

@export var corpsePrompt: Resource

@export var speedAmount: int = 20
@export var jumpAmount: int = -36
@export var batteryAmount: int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	type = upgradeType.CORPSE
	

	
	
func GraveRobbing(player):
	var prompt = corpsePrompt.instantiate()
	prompt.position = position - Vector2(0, 100)
	get_tree().current_scene.add_child(prompt)
	player.maxSpeed += upgradeAmount*speedAmount
	player.speedParts += upgradeAmount
	player.jumpSpeed += upgradeAmount*jumpAmount
	player.jumpParts += upgradeAmount
	player.maxBattery += upgradeAmount*batteryAmount
	player.batteryParts += upgradeAmount
	get_parent().queue_free()

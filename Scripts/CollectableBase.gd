extends Area2D

class_name CollectableBase

@export var speedPrompt: Resource
@export var jumpPrompt: Resource
@export var batteryPrompt: Resource
@export var refillPrompt: Resource

@export var upgradeAmount: float
enum upgradeType {SPEED, JUMP, BATTERY, REFILL, PRIME, CORPSE}

var type

func OnPickup(player):
	PlayAudio(player)
	if type == upgradeType.SPEED:
		player.maxSpeed += upgradeAmount
		player.speedParts += 1
		var prompt = speedPrompt.instantiate()
		prompt.position = position - Vector2(0, 100)
		get_tree().current_scene.add_child(prompt)
		queue_free()
	if type == upgradeType.JUMP:
		player.jumpSpeed += upgradeAmount
		player.jumpParts += 1
		var prompt = jumpPrompt.instantiate()
		prompt.position = position - Vector2(0, 100)
		get_tree().current_scene.add_child(prompt)
		queue_free()
	if type == upgradeType.BATTERY:
		player.maxBattery += upgradeAmount
		player.batteryParts += 1
		var prompt = batteryPrompt.instantiate()
		prompt.position = position - Vector2(0, 100)
		get_tree().current_scene.add_child(prompt)
		queue_free()
	if type == upgradeType.PRIME:
		PrimeUpgrade(player)
		queue_free()
	if type == upgradeType.CORPSE:
		GraveRobbing(player)
	if type == upgradeType.REFILL:
		var prompt = refillPrompt.instantiate()
		prompt.position = position - Vector2(0, 100)
		get_tree().current_scene.add_child(prompt)
		player.battery += upgradeAmount
		if player.battery > player.maxBattery:
			player.battery = player.maxBattery
		call_deferred("Disable")
		hide()

func PrimeUpgrade(_player):
	pass
	
func GraveRobbing(player):
	pass
	
func Disable():
	$CollisionShape2D.disabled = true

func PlayAudio(player):
	if type == upgradeType.PRIME:
		player.find_child("PrimePart").play()
	else:
		player.find_child("Part").play()

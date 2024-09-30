extends Area2D

class_name CollectableBase

const speedPrompt = preload("res://Prefabs/UI/SpeedPartPrompt.tscn")
const jumpPrompt = preload("res://Prefabs/UI/JumpPartPrompt.tscn")
const batteryPrompt = preload("res://Prefabs/UI/BatteryPartPrompt.tscn")
const refillPrompt = preload("res://Prefabs/UI/RefillPrompt.tscn")
const corpsePrompt = preload("res://Prefabs/UI/CorpsePrompt.tscn")

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
		var prompt = corpsePrompt.instantiate()
		prompt.position = position - Vector2(0, 100)
		get_tree().current_scene.add_child(prompt)
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

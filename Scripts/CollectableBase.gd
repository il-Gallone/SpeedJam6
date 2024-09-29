extends Area2D

class_name CollectableBase

@export var upgradeAmount: float
enum upgradeType {SPEED, JUMP, BATTERY, PRIME, CORPSE}

var type

func OnPickup(player):
	if type == upgradeType.SPEED:
		player.maxSpeed += upgradeAmount
		player.speedParts += 1
	if type == upgradeType.JUMP:
		player.jumpSpeed += upgradeAmount
		player.jumpParts += 1
	if type == upgradeType.BATTERY:
		player.maxBattery += upgradeAmount
		player.batteryParts += 1
	if type == upgradeType.PRIME:
		PrimeUpgrade(player)
	queue_free()
	if type == upgradeType.CORPSE:
		GraveRobbing(player)

func PrimeUpgrade(_player):
	pass
	
func GraveRobbing(player):
	pass

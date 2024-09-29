extends Area2D

class_name CollectableBase

@export var upgradeAmount: float
enum upgradeType {SPEED, JUMP, BATTERY, REFILL, PRIME, CORPSE}

var type

func OnPickup(player):
	if type == upgradeType.SPEED:
		player.maxSpeed += upgradeAmount
		player.speedParts += 1
		queue_free()
	if type == upgradeType.JUMP:
		player.jumpSpeed += upgradeAmount
		player.jumpParts += 1
		queue_free()
	if type == upgradeType.BATTERY:
		player.maxBattery += upgradeAmount
		player.batteryParts += 1
		queue_free()
	if type == upgradeType.PRIME:
		PrimeUpgrade(player)
		queue_free()
	if type == upgradeType.CORPSE:
		GraveRobbing(player)
	if type == upgradeType.REFILL:
		player.battery += upgradeAmount
		if player.battery > player.maxBattery:
			player.battery = player.maxBattery
		monitorable = false
		hide()

func PrimeUpgrade(_player):
	pass
	
func GraveRobbing(player):
	pass

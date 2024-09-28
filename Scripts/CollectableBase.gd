extends Area2D

class_name CollectableBase

@export var upgradeAmount: float
enum upgradeType {SPEED, JUMP, BATTERY, PRIME}

var type

func OnPickup(player):
	if type == upgradeType.SPEED:
		player.maxSpeed += upgradeAmount
	if type == upgradeType.JUMP:
		player.jumpSpeed += upgradeAmount
	if type == upgradeType.BATTERY:
		player.maxBattery += upgradeAmount
	if type == upgradeType.PRIME:
		PrimeUpgrade(player)
	queue_free()

func PrimeUpgrade(_player):
	pass

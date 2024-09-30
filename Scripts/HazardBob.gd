extends Hazard

@export var patrolX: float
@export var patrolY: float
@export var patrolTimeX:float = 4.0
@export var patrolTimeY:float = 0.0

@onready var animatedSprite = $AnimatedSprite2D

var speedX
var speedY

var originX
var originY

var patrolProgress = 0
	

func _ready() -> void:
	if patrolTimeY == 0:
		animatedSprite.play("Roll")
	else:
		animatedSprite.play("Float")
	if patrolTimeX > 0:
		speedX = (patrolX/patrolTimeX)*2
	else:
		speedX = 0
	if patrolTimeY > 0:
		speedY = (patrolY/patrolTimeY)*2
	else:
		speedY = 0
	originX = position.x
	originY = position.y
	
		
func _physics_process(delta: float) -> void:
	position += Vector2(speedX, speedY)*delta
	if position.x >= originX + patrolX:
		position.x = originX + patrolX
		speedX *= -1
	if position.x <= originX:
		position.x = originX
		speedX *= -1
	if position.y >= originY + patrolY:
		position.y = originY + patrolY
		speedY *= -1
	if position.y <= originY:
		position.y = originY
		speedY *= -1
	patrolProgress += delta
	if patrolProgress >= 0.1:
		if patrolTimeY == 0:
			if animatedSprite.animation == "Turn":
				animatedSprite.play("Roll")
	if patrolProgress >= patrolTimeX / 2 - 0.1 and patrolProgress <= patrolTimeX / 2 + 0.1 :
		if patrolTimeY == 0:
			animatedSprite.play("Turn")
		animatedSprite.flip_h = true
	if patrolProgress >= patrolTimeX / 2 + 0.1 and patrolTimeY == 0:
		if patrolTimeY == 0:
			if animatedSprite.animation == "Turn":
				animatedSprite.play("Roll")
	if patrolProgress >= patrolTimeX - 0.1 or patrolProgress <= 0.1:
		if patrolTimeY == 0:
			animatedSprite.play("Turn")
		animatedSprite.flip_h = false
	if patrolProgress >= patrolTimeX:
		patrolProgress = 0

	

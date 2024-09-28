extends CharacterBody2D


@export_category("Movement Parameters")
@export var maxSpeed: float = 150.0
@export var acceleration: float = 150.0
@export var jump_speed: float = -400.0
@export var airMaxSpeedMod: int = 3
@export var frictionMod: float = 300.0
@export var maxSpeedDecel: float = 12.5
@export var jumpBufferTime: float = 0.1

var maxBattery: float = 500.0
var battery: float = 500.0

var jumpBuffer:bool = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_speed
		battery -= 1.5
		
		
	var accelDir = Input.get_axis("ui_left", "ui_right")
	if accelDir != 0:
		battery -= 1 * delta
	
	if is_on_floor():
		if accelDir == 0:
			if velocity.x < 0:
				velocity.x += frictionMod * delta
				if velocity.x > 0:
					velocity.x  = 0
			if velocity.x > 0:
				velocity.x -= frictionMod * delta
				if velocity.x < 0:
					velocity.x  = 0
		if velocity.x > maxSpeed:
			velocity.x -= maxSpeedDecel * delta
			if accelDir < 0:
				velocity.x += acceleration * accelDir * delta
		elif velocity.x < -maxSpeed:
			velocity.x += maxSpeedDecel * delta
			if accelDir > 0:
				velocity.x += acceleration * accelDir * delta
		else:
			velocity.x += acceleration * accelDir * delta
			if velocity.x > 0 and accelDir < 0:
				velocity.x -= frictionMod * delta
			if velocity.x < 0 and accelDir > 0:
				velocity.x += frictionMod * delta
			if velocity.x >= maxSpeed:
				velocity.x = maxSpeed
			if velocity.x <= -maxSpeed:
				velocity.x = -maxSpeed
	else:
		if velocity.x > maxSpeed * airMaxSpeedMod:
			velocity.x -= maxSpeedDecel * delta
			if accelDir < 0:
				velocity.x += acceleration * accelDir * delta
		elif velocity.x < -maxSpeed * airMaxSpeedMod:
			velocity.x += maxSpeedDecel * delta
			if accelDir > 0:
				velocity.x += acceleration * accelDir * delta
		else:
			velocity.x += acceleration * accelDir * delta
			if velocity.x >= maxSpeed * airMaxSpeedMod:
				velocity.x = maxSpeed * airMaxSpeedMod
			if velocity.x <= -maxSpeed * airMaxSpeedMod:
				velocity.x = -maxSpeed * airMaxSpeedMod
		
		
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Charger":
			if velocity.x == 0 and battery < maxBattery:
				battery += 100 * delta
				if battery > maxBattery:
					battery = maxBattery
	

extends CharacterBody2D


var maxSpeed = 150.0
var acceleration = 150.0
var jump_speed = -400.0
var airMaxSpeedMod = 3
var frictionMod = 300.0
var maxSpeedDecel = 12.5

var maxBattery = 500.0
var battery = 500.0

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
	

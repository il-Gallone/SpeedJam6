extends CharacterBody2D


@export_category("Movement Parameters")
@export var maxSpeed: float = 400.0
@export var acceleration: float = 800.0
@export var jump_speed: float = -800.0
@export var airMaxSpeedMod: int = 2
@export var frictionMod: float = 800.0
@export var maxSpeedDecel: float = 1000
@export var jumpBufferTime: float = 0.1
@export var maxJumpsAvailable: int = 1
@export var maxGrappleLength: float = 900.0


var maxBattery: float = 500.0
var battery: float = 500.0

var jumpBuffer:bool = false
var jumpsAvailable:int = 1

var hookPos
var isHookFlying: bool = false
var isHooked: bool = false
var isHookReturning: bool = false
var isHookReady: bool = true
var hookRopeLength: float = 0.0
var hookDir:int = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
		
	var accelDir = Input.get_axis("ui_left", "ui_right")
	if accelDir != 0:
		if !isHookFlying:
			hookDir = int(accelDir)
		battery -= 1 * delta
	
	if is_on_floor():
		jumpsAvailable = maxJumpsAvailable
		if jumpBuffer:
			Jump()
			jumpBuffer = false
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
		
		
	if isHookFlying:
		HookExtend(delta)
	elif isHooked:
		HookSwing(delta)
	elif isHookReturning:
		HookReturn(delta)
	
	if Input.is_action_just_pressed("jump"):
		if jumpsAvailable > 0:
			Jump()
		else:
			jumpBuffer = true
			get_tree().create_timer(jumpBufferTime).timeout.connect(On_Jump_Buffer_Timeout)
			
	if Input.is_action_just_pressed("grapple") && isHookReady:
		isHookFlying = true
		isHookReady = false
		
	if !Input.is_action_pressed("grapple") && !isHookReturning:
		isHookReturning = true
		isHooked = false
		isHookFlying = false
		
	
	print(isHookReady)
	
	print(isHookReturning)
	
	print(isHooked)
	
	print(isHookFlying)
	move_and_slide()
	
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Charger":
			if velocity.x == 0 and battery < maxBattery:
				battery += 100 * delta
				if battery > maxBattery:
					battery = maxBattery
					
func Jump()-> void:
	velocity.y = jump_speed
	battery -= 1.5
	jumpsAvailable -= 1
	
func HookExtend(delta):
	$GrapplingHook.target_position += Vector2(6000*hookDir, -6000)*delta
	if $GrapplingHook.target_position.y < -maxGrappleLength:
		$GrapplingHook.target_position = Vector2(maxGrappleLength*hookDir, -maxGrappleLength)
		isHookFlying = false
	$Rope.remove_point(1)
	$Rope.add_point($GrapplingHook.target_position)
	hookPos = Get_Hook_Pos()
	if !hookPos and !isHookFlying:
		isHookReturning = true
	if hookPos:
		isHookFlying = false
		isHooked = true
		isHookReturning = false
		
func HookReturn(delta):
	$GrapplingHook.target_position -= $GrapplingHook.target_position.normalized()*5000*delta
	if $GrapplingHook.target_position.y > 0:
		$GrapplingHook.target_position = Vector2(0, 0)
		isHookFlying = false
		isHooked = false
		isHookReturning = false
		isHookReady= true
	$Rope.remove_point(1)
	$Rope.add_point($GrapplingHook.target_position)
	
func HookSwing(_delta):
	var radius = global_position - hookPos
	var angle = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var radVel = cos(angle) * velocity.length()
	velocity += radius.normalized() * -radVel
	$GrapplingHook.target_position = to_local(hookPos)
	$Rope.remove_point(1)
	$Rope.add_point($GrapplingHook.target_position)
	
	
func Get_Hook_Pos():
	if $GrapplingHook.is_colliding():
		return $GrapplingHook.get_collision_point()
	else:
		return false
	
func On_Jump_Buffer_Timeout() -> void:
	jumpBuffer = false
	

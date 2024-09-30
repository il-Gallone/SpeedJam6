extends CharacterBody2D

const PlayerCorpse = preload("res://Prefabs/PlayerCorpse.tscn")
const JumpParticle = preload("res://Prefabs/jumpParticle.tscn")
const DashParticle = preload("res://Prefabs/DashParticle.tscn")

@export_category("Movement Parameters")
@export var maxSpeed: float = 400.0
@export var acceleration: float = 1200.0
@export var jumpSpeed: float = -720.0
@export var airMaxSpeedMod: int = 2
@export var frictionMod: float = 1200.0
@export var maxSpeedDecel: float = 1400
@export var jumpBufferTime: float = 0.1
@export var maxJumpsAvailable: int = 1
@export var maxGrappleLength: float = 900.0
@export var dashTime: float = 0.2


var maxBattery: float = 500.0
var battery: float = 500.0

var jumpBuffer:bool = false
var jumpsAvailable:int = 1

var isDashing = false
var dashesAvailable = false
var dashCD: float = 0

var facingDir:int = 1

var hookPos
var isHookFlying: bool = false
var isHooked: bool = false
var isHookReturning: bool = false
var isHookReady: bool = false
var hookRopeLength: float = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var speedParts = 0
var jumpParts = 0
var batteryParts = 0

@onready var animatedSprite = $AnimatedSprite2D
var isInAir = false

var isCharging = false

var invincTime = 0

var lastCheckpoint

func _ready() -> void:
	$GrapplingHook/Grapple.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !$Camera2D/Leaderboard.scorePaused:
		if battery > 0:
			invincTime -= delta
			if velocity.y < 10 and velocity.y > -10 and isInAir:
				animatedSprite.play("Float")
			elif velocity.y > 10:
				animatedSprite.play("Fall")
				isInAir = true
			if velocity.x > 0:
				animatedSprite.flip_h = false
				$GrapplingHook.position.x = -42
			elif velocity.x < 0:
				animatedSprite.flip_h = true
				$GrapplingHook.position.x = 42
			if isDashing:
				Dash(delta)
			else:
				var accelDir = Input.get_axis("ui_left", "ui_right")
				if dashCD > 0:
					dashCD -= delta
				velocity.y += gravity * delta
				if accelDir != 0:
					if !isHookFlying:
						facingDir = int(accelDir)
					battery -= 1 * delta
				if is_on_floor():
					if isCharging:
						battery += 400 * delta
						if battery > maxBattery:
							battery = maxBattery
					if isInAir:
						animatedSprite.play("Landing")
						$Land.play()
						isInAir = false
					jumpsAvailable = maxJumpsAvailable
					if !animatedSprite.animation == "Landing":
						if velocity.x <= 5 and velocity.x >= -5:
							animatedSprite.play("Idle")
						else:
							animatedSprite.play("WalkCycle")
							animatedSprite.speed_scale = abs(velocity.x/200)
							if animatedSprite.frame == 2:
								$Step_A.play()
							if animatedSprite.frame == 5:
								$Step_B.play()
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
					animatedSprite.speed_scale = 1
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
					
				if Input.is_action_just_pressed("dash") and dashesAvailable and dashCD <= 0:
					if !isHookFlying and !isHooked:
						battery -= 15
						dashCD = dashTime
						isDashing = true
						$Dash.play()
						var newParticle = DashParticle.instantiate()
						if animatedSprite.flip_h:
							newParticle.position = Vector2(112, -16)
							newParticle.flip_h = true
						else:
							newParticle.position = Vector2(-112, -16)
						self.add_child(newParticle)
				
				if Input.is_action_just_pressed("jump") && !isHooked:
					if jumpsAvailable > 0:
						Jump()
					else:
						jumpBuffer = true
						get_tree().create_timer(jumpBufferTime).timeout.connect(On_Jump_Buffer_Timeout)
						
				if Input.is_action_just_pressed("grapple") && isHookReady:
					animatedSprite.play("Float")
					isHookFlying = true
					isHookReady = false
					
				if !Input.is_action_pressed("grapple") && !isHookReturning:
					isHookReturning = true
					isHooked = false
					isHookFlying = false
				
			var previousVel = velocity
			move_and_slide()
			
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				if collision.get_collider().has_method("DamagePlayer"):
					velocity = (previousVel.bounce(collision.get_normal())).normalized()*-jumpSpeed
					if isHooked:
						isHooked = false
						isHookReturning = true
					if invincTime <= 0:
						collision.get_collider().DamagePlayer(self)
						invincTime = 0.5
			
			if battery <= 0:
				Death()
		else:
			if animatedSprite.animation != "Death":
				Respawn()
				

func Death()-> void:
	animatedSprite.play("Death")
	velocity = Vector2.ZERO
	
func Respawn() -> void:
	var lowestPartCount = 5
	if speedParts < lowestPartCount:
		lowestPartCount = speedParts
	if jumpParts < lowestPartCount:
		lowestPartCount = jumpParts
	if batteryParts < lowestPartCount:
		lowestPartCount = batteryParts
	if lowestPartCount != 0:
		var deathPos = position
		var newCorpse = PlayerCorpse.instantiate()
		newCorpse.position = deathPos
		newCorpse.find_child("CorpseArea").upgradeAmount = lowestPartCount
		get_tree().current_scene.add_child(newCorpse)
		LostParts(lowestPartCount, "all")
	battery = maxBattery
	for refill in get_tree().get_nodes_in_group("Refills"):
		refill.Respawn()
	position = lastCheckpoint.global_position
	velocity = Vector2.ZERO
	HookReset()
	
func LostParts(partCount, type):
	if type == "speed" or type == "all":
		maxSpeed -= 20*partCount
		speedParts -= partCount
	if type == "jump" or type == "all":
		jumpSpeed -= -36*partCount
		jumpParts -= partCount
	if type == "battery" or type == "all":
		maxBattery -= 100*partCount
		batteryParts -= partCount
	
					
func Jump()-> void:
	isInAir = true
	$Jump.play()
	velocity.y = jumpSpeed
	battery -= 10
	jumpsAvailable -= 1
	animatedSprite.play("Jump")
	if !is_on_floor():
		var newParticle = JumpParticle.instantiate()
		newParticle.position = Vector2(0, 116)
		self.add_child(newParticle)
		
	
func Dash(delta)-> void:
	velocity.x += facingDir*acceleration*2*delta
	velocity.y = 0
	dashCD -= delta
	if dashCD <= 0:
		isDashing = false
		dashCD = 0.5
	
	
func HookExtend(delta):
	$GrapplingHook/Grapple.show()
	$GrapplingHook/Grapple.rotation = 45*facingDir
	$GrapplingHook.target_position += Vector2(5500*facingDir, -5500)*delta
	if $GrapplingHook.target_position.y < -maxGrappleLength:
		$GrapplingHook.target_position = Vector2(maxGrappleLength*facingDir, -maxGrappleLength)
		isHookFlying = false
	$GrapplingHook/Rope.remove_point(1)
	$GrapplingHook/Rope.add_point($GrapplingHook.target_position)
	$GrapplingHook/Grapple.position = $GrapplingHook.target_position
	
	hookPos = Get_Hook_Pos()
	if !hookPos and !isHookFlying:
		isHookReturning = true
	if hookPos:
		print($GrapplingHook/Grapple.position)
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
		$GrapplingHook/Grapple.hide()
	$GrapplingHook/Rope.remove_point(1)
	$GrapplingHook/Rope.add_point($GrapplingHook.target_position)
	$GrapplingHook/Grapple.position = $GrapplingHook.target_position
	
func HookSwing(_delta):
	var radius = global_position - hookPos
	var angle = acos(radius.dot(velocity) / (radius.length() * velocity.length()))
	var radVel = cos(angle) * velocity.length()
	velocity += radius.normalized() * -radVel
	$GrapplingHook.target_position = to_local(hookPos)
	if animatedSprite.flip_h:
		$GrapplingHook.target_position -= Vector2(42, 0)
	else:
		$GrapplingHook.target_position += Vector2(42, 0)
	$GrapplingHook/Rope.remove_point(1)
	$GrapplingHook/Rope.add_point($GrapplingHook.target_position)
	var Rope1: Vector2 = $GrapplingHook/Rope.get_point_position(0)
	var Rope2: Vector2 = $GrapplingHook/Rope.get_point_position(1)
	$GrapplingHook/Grapple.rotation = (rad_to_deg(Rope1.angle_to_point(Rope2))/84)-24
	$GrapplingHook/Grapple.position = $GrapplingHook.target_position
	
func HookReset():
	if isHookReady or isHookFlying or isHooked or isHookReturning:
		$GrapplingHook.target_position = Vector2(0, 0)
		isHookFlying = false
		isHooked = false
		isHookReturning = false
		isHookReady= true
		$GrapplingHook/Grapple.hide()
		$GrapplingHook/Rope.remove_point(1)
		$GrapplingHook/Rope.add_point($GrapplingHook.target_position)
		$GrapplingHook/Grapple.position = $GrapplingHook.target_position
		
	
	
func Get_Hook_Pos():
	if $GrapplingHook.is_colliding():
		return $GrapplingHook.get_collision_point()
	else:
		return false
	
func On_Jump_Buffer_Timeout() -> void:
	jumpBuffer = false
	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_method("OnPickup"):
		area.OnPickup(self)
	if area.has_method("Checkpoint"):
		isCharging = true
		if lastCheckpoint:
			lastCheckpoint.NotCheckpoint()
		area.Checkpoint()
		lastCheckpoint = area
	if area.has_method("PlayerContact"):
		area.PlayerContact(self)
		
			
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.has_method("Checkpoint"):
		isCharging = false
		
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animatedSprite.animation == "Landing":
		animatedSprite.play("Idle")


func _on_audio_stream_player_finished() -> void:
	$Music.play()


func _on_button_pressed() -> void:
	$Music.play()

extends Control


@export var id = ""
var inputType

var Sprite
var Sprite2

func _process(delta: float) -> void:
	if Input.get_connected_joypads().size() > 0:
		inputType = Input.get_joy_name(0)
	else:
		inputType = "MKB"
	if id == "MoveJump":
		Sprite = $MoveSprite
		Sprite2 = $JumpSprite
		if inputType == "MKB":
			Sprite2.frame = 0
		elif inputType == "PS4 Controller" or inputType == "PS5 Controller":
			Sprite2.frame = 2
		else:
			Sprite2.frame = 1
		if Input.is_action_just_pressed("jump") or Input.get_axis("ui_left", "ui_right") != 0:
			Fadeout()
	if id == "Dash":
		Sprite = $DashSprite
		if Input.is_action_just_pressed("dash"):
			Fadeout()
	if id == "Grapple":
		Sprite = $GrappleSprite
		if Input.is_action_just_pressed("grapple"):
			Fadeout()
	if id == "AirJump1":
		Sprite = $JumpSprite
		if Input.is_action_just_pressed("jump"):
			Fadeout()
	if id != "AirJump2+" and id != "Part":
		if inputType == "MKB":
			Sprite.frame = 0
		elif inputType == "PS4 Controller" or inputType == "PS5 Controller":
			Sprite.frame = 2
		else:
			Sprite.frame = 1
	else:
		Fadeout()

func Fadeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 4)

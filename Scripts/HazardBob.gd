extends "res://Scripts/Hazard.gd"

@export var patrolX: float
@export var patrolY: float
@export var patrolTimeX = 4
@export var patrolTimeY = 0

var patrolProgress
	

func _ready() -> void:
	if patrolTimeY == 0:
		$AnimatedSprite2D.play("Roll")
	else:
		$AnimatedSprite2D.play("Float")
	start_tween()
	
func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	if patrolTimeX > 0:
		tween.tween_property(self, "position", Vector2(patrolX, 0), patrolTimeX / 2)
		tween.tween_property(self, "position", Vector2.ZERO, patrolTimeX / 2)
	if patrolTimeY > 0:
		tween.tween_property(self, "position", Vector2(0, patrolY), patrolTimeY / 2)
		tween.tween_property(self, "position", Vector2.ZERO, patrolTimeY / 2)
		
func _process(delta: float) -> void:
	patrolProgress += delta
	if patrolProgress >= patrolTimeX / 2 - 0.1 and patrolProgress <= patrolTimeX / 2 + 0.1 :
		if patrolTimeY == 0:
			$AnimatedSprite2D.play("Turn")
		$AnimatedSprite2D.flip_h = true
	if patrolProgress >= patrolTimeX / 2 + 0.1 and patrolTimeY == 0:
		if $AnimatedSprite2D.is_playing("Turn"):
			$AnimatedSprite2D.play("Roll")
	if patrolProgress >= patrolTimeX  - 0.1 or patrolProgress <= 0.1:
		if patrolTimeY == 0:
			$AnimatedSprite2D.play("Turn")
		$AnimatedSprite2D.flip_h = false
	

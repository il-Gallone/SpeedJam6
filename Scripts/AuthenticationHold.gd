extends ColorRect


var dots = ""

var dotTime = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	find_child("Button").disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !get_parent().find_child("Leaderboard").authenticationComplete:
		dotTime -= delta
		if dotTime <= 0:
			dotTime = 0.2
			if dots == "...":
				dots = ""
			else:
				dots = dots + "."
		find_child("AuthLabel").text = "AUTHENTICATING" + dots
	else:
		find_child("AuthLabel").text = "LOGIN COMPLETE"
		find_child("Button").disabled = false


func _on_button_pressed() -> void:
	find_child("Button").disabled = true
	get_parent().find_child("Leaderboard").scorePaused = false
	hide()

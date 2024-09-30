extends Label

var timeDelta: float = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	timeDelta = get_parent().get_parent().find_child("Leaderboard").score
	var timeMinutes: int = floor(timeDelta/60)
	var timeSeconds: int = floor(timeDelta - timeMinutes * 60)
	var timeMilliseconds: int = ((timeDelta - timeMinutes * 60)-timeSeconds)*100
	
	var timeFormat = "%02d:%02d:%02d"
	text = timeFormat % [timeMinutes, timeSeconds, timeMilliseconds]

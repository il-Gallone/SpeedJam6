extends Area2D

var scoreSubmitted = false

func PlayerContact(player) -> void:
	player.find_child("Leaderboard").scorePaused = true
	if !scoreSubmitted:
		player.find_child("Leaderboard").SubmitScore()
		scoreSubmitted = true
	

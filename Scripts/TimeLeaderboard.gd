extends TextEdit

# Use this game API key if you want to test with a functioning leaderboard
# "987dbd0b9e5eb3749072acc47a210996eea9feb0"
var game_API_key = "dev_0b9fb3100aa046a6b6660541ca0221ee"
var development_mode = true
var leaderboard_key = "fastestTime"
var session_token = ""
var score = 0
var playerInput = false
var scorePaused = true
var authenticationComplete = false

# HTTP Request node can only handle one call per node
var auth_http = HTTPRequest.new()
var leaderboard_http = HTTPRequest.new()
var submit_score_http = HTTPRequest.new()

var set_name_http = HTTPRequest.new()
var get_name_http = HTTPRequest.new()

func _ready():
	_authentication_request()
	hide()
	get_parent().find_child("SubmitButton").hide()
	get_parent().find_child("Leaderboard Display Top").hide()
	get_parent().find_child("Leaderboard Display Personal").hide()

func _process(delta):
	if playerInput and !scorePaused:
		score += delta
	else:
		if authenticationComplete and !scorePaused:
			if Input.is_action_just_pressed("jump") or Input.get_axis("ui_left", "ui_right") != 0:
				playerInput = true


func _authentication_request():
	# Check if a player session exists
	var player_session_exists = false
	var player_identifier : String
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	if file != null:
		player_identifier = file.get_as_text()
		print("player ID="+player_identifier)
		file.close()
 
	if player_identifier != null and player_identifier.length() > 1:
		print("player session exists, id="+player_identifier)
		player_session_exists = true
	if(player_identifier.length() > 1):
		player_session_exists = true
		
	## Convert data to json string:
	var data = { "game_key": game_API_key, "game_version": "0.0.0.1", "development_mode": true }
	
	# If a player session already exists, send with the player identifier
	if(player_session_exists == true):
		data = { "game_key": game_API_key, "player_identifier":player_identifier, "game_version": "0.1.0.0", "development_mode": true }
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	# Create a HTTPRequest node for authentication
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request_completed.connect(_on_authentication_request_completed)
	# Send request
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	print(data)


func _on_authentication_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Save the player_identifier to file
	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	file.store_string(json.get_data().player_identifier)
	file.close()
	
	# Save session_token to memory
	session_token = json.get_data().session_token
	
	# Print server response
	print(json.get_data())
	
	# Clear node
	auth_http.queue_free()
	authenticationComplete = true
	# Get leaderboards
	_get_leaderboards()


func _get_leaderboards():
	print("Getting leaderboards")
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	
	# Send request
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")

func _on_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	
	# Formatting as a leaderboard
	var leaderboardTopFormatted = ""
	var leaderboardPersonalFormatted = ""
	
	if not json.get_data().items:
		return
	
	for n in min(json.get_data().items.size(), 10):
		leaderboardTopFormatted += str(json.get_data().items[n].rank)+str(". ")
		leaderboardTopFormatted += str(json.get_data().items[n].metadata)+str(" - ")
		var timeScore = json.get_data().items[n].score / 1000
		var timeMinutes: int = floor(timeScore/60)
		var timeSeconds: int = floor(timeScore - timeMinutes * 60)
		var timeMilliseconds: int = ((timeScore - timeMinutes * 60)-timeSeconds)*100
		var timeFormat = "%02d:%02d:%02d \n"
		leaderboardTopFormatted += timeFormat % [timeMinutes, timeSeconds, timeMilliseconds]
	# Print the formatted leaderboard to the console
	get_parent().find_child("TopRankings").text = leaderboardTopFormatted
	
	var foundPlayer = false
	for n in json.get_data().items.size():
		match OS.get_name():
			"HTML5", "Windows", "X11":
				if json.get_data().items[n].member_id == OS.get_unique_id():
					foundPlayer = true
					var timeScore
					var timeMinutes: int
					var timeSeconds: int
					var timeMilliseconds: int
					var timeFormat = "%02d:%02d:%02d \n"
					for m in n+1:
						if m == 0:
							m = n -9
							if m < 0:
								m = 0
						leaderboardPersonalFormatted += str(json.get_data().items[m].rank)+str(". ")
						leaderboardPersonalFormatted += str(json.get_data().items[m].metadata)+str(" - ")
						timeScore = json.get_data().items[m].score / 1000
						timeMinutes = floor(timeScore/60)
						timeSeconds = floor(timeScore - timeMinutes * 60)
						timeMilliseconds = ((timeScore - timeMinutes * 60)-timeSeconds)*100
						leaderboardPersonalFormatted += timeFormat % [timeMinutes, timeSeconds, timeMilliseconds]
				elif !foundPlayer:
					leaderboardPersonalFormatted = "Not Ranked"
	get_parent().find_child("PersonalRankings").text = leaderboardPersonalFormatted
							
	
	# Clear node
	leaderboard_http.queue_free()


func SubmitScore() -> void:
	show()
	get_parent().find_child("SubmitButton").show()
	editable = true

func _upload_score(score: int):
	match OS.get_name():
		"HTML5", "Windows", "X11":
			var data = { "score": str(score), "member_id": OS.get_unique_id(), "metadata": text}
			var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
			submit_score_http = HTTPRequest.new()
			add_child(submit_score_http)
			submit_score_http.request_completed.connect(_on_upload_score_request_completed)
			# Send request
			submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
			# Print what we're sending, for debugging purposes:
			print(data)

func _change_player_name():
	print("Changing player name")
	
	# use this variable for setting the name of the player
	var player_name = text
	
	var data = { "name": str(player_name) }
	var url =  "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	set_name_http = HTTPRequest.new()
	add_child(set_name_http)
	set_name_http.request_completed.connect(_on_player_set_name_request_completed)
	# Send request
	set_name_http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	
func _on_player_set_name_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	set_name_http.queue_free()

func _get_player_name():
	print("Getting player name")
	var url = "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	get_name_http = HTTPRequest.new()
	add_child(get_name_http)
	get_name_http.request_completed.connect(_on_player_get_name_request_completed)
	# Send request
	get_name_http.request(url, headers, HTTPClient.METHOD_GET, "")

func _on_player_get_name_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	# Print player name
	print(json.get_data().name)

func _on_upload_score_request_completed(result, response_code, headers, body) :
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	
	# Clear node
	submit_score_http.queue_free()


func _on_submit_button_pressed() -> void:
	_change_player_name()
	hide()
	get_parent().find_child("SubmitButton").hide()
	get_parent().find_child("Leaderboard Display Top").show()
	get_parent().find_child("Leaderboard Display Personal").show()
	_upload_score(score*1000)
	_get_leaderboards()
	

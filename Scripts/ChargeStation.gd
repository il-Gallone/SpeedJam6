extends Node

var isCurrentCheckpoint = false

func Checkpoint() -> void:
	isCurrentCheckpoint = true
		

func NotCheckpoint() -> void:
	isCurrentCheckpoint = false

extends ColorRect

func _process(_delta: float) -> void:
	size.x = find_parent("Player").battery

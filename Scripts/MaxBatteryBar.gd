extends TextureRect

func _process(_delta: float) -> void:
	size.x = find_parent("Player").maxBattery

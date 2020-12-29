extends Control

signal start

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("continue"):
		self.emit_signal("start")
		self.set_process(false)

extends Node2D

signal can_heal
signal changed_health

func _ready() -> void:
	$Player/Camera2D.current = false
	
	self.pause_mode = Node.PAUSE_MODE_STOP
	self.set_physics_process(false)
	
	$CanvasLayer/Health.Game = self.get_path()

func _physics_process(delta : float) -> void:
	pass

extends Node2D

func _process(delta : float) -> void:
	pass

func _on_Start_start():
	$Start.visible = false
	$Game.visible = true
	
	$Game.pause_mode = Node.PAUSE_MODE_PROCESS
	$Game.set_physics_process(true)
		
	$Game/CanvasLayer/Health.visible = true
	$Game/Player/Camera2D.current = true

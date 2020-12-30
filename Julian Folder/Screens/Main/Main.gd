extends Node2D

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("mute"):
		$Mute.muteAll()

func _on_Start_start():
	$Start.visible = false
	$Game.visible = true
	
	$Game.pause_mode = Node.PAUSE_MODE_PROCESS
	$Game.set_physics_process(true)
	
	$Game/CanvasLayer/Health.visible = true
	$Game/Player/Camera2D.current = true
	
	$Game.start_level(1)

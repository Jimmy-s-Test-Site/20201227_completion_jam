extends Node2D

func _ready() -> void:
	$Start.set_process(true)
	$Game.set_process(false)
	$"CanvasLayer/Death Screen".set_process(false)
	
	$Start.set_physics_process(true)
	$Game.set_physics_process(false)
	$"CanvasLayer/Death Screen".set_physics_process(false)

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("mute"):
		$Mute.toggle_mute_all()
	
	if Input.is_action_just_pressed("quit"):
		# simulate game over
		self._on_Game_game_over($Game.level)

func _on_Start_start():
	$Start.visible = false
	$Game.visible = true
	
	$Game.set_physics_process(true)
	
	$Game/CanvasLayer/Health.visible = true
	$Game/Player/Camera2D.current = true
	
	$Game/Player.reset()
	
	$Game.start_level(1)


func _on_Game_game_over(score : int):
	$Game/CanvasLayer/Health.visible = false
	$Game/Player/Camera2D.current = false
	
	for enemy in $Game/Enemies.get_children():
		enemy.queue_free()
	
	$Game.visible = false
	$"CanvasLayer/Death Screen".visible = true
	
	$"CanvasLayer/Death Screen".set_process(true)
	$Game.set_physics_process(false)
	
	$"CanvasLayer/Death Screen".setScore(score)


func _on_Death_Screen_startAgain():
	$"CanvasLayer/Death Screen".visible = false
	$Game.visible = true
	
	$Game.set_physics_process(true)
	
	$Game/CanvasLayer/Health.visible = true
	$Game/Player/Camera2D.current = true
	
	$Game/Player.reset()
	
	$Game.start_level(1)

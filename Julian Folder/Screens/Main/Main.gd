extends Node2D

func _process(delta : float) -> void:
	print("does this work?")

func _on_Start_start():
	$Start.visible = false
	$Game.visible = true
	
	$Game.pause_mode = Node.PAUSE_MODE_PROCESS
	$Game.set_physics_process(true)
	
	$Game/CanvasLayer/Health.visible = true
	$Game/Player/Camera2D.current = true
	
	#var new_n = $Game.N_resource.instance()
	#$Game.add_child(new_n)
	
	#new_n.name = "BobRoss"
	#new_n.position = $Game.get_node(self.n_r_spawn_points_nodepaths).position
	#new_n.path2D = $Game.n_r_paths_nodepaths
	
	#print(new_n.position)
	
	

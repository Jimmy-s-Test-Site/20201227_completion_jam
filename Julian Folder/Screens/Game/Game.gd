extends Node2D

export (PackedScene) var N_scene
export (PackedScene) var R_scene
export (PackedScene) var C_scene

export (NodePath) var c_spawn_point_nodepaths
export (NodePath) var c_paths_nodepaths
export (NodePath) var n_r_spawn_points_nodepaths
export (NodePath) var n_r_paths_nodepaths

export (float) var enemy_spawn_cooldown : float = 0.5

export (int) var initial_ns_to_spawn : int = 10
export (int) var initial_rs_to_spawn : int =  0
export (int) var initial_cs_to_spawn : int =  0

var ns_to_spawn : int = 0
var rs_to_spawn : int = 0
var cs_to_spawn : int = 0

var level = 1

func _ready() -> void:
	$Player/Camera2D.current = false
	
	self.set_physics_process(false)
	
	$CanvasLayer/Health.visible = false
	$CanvasLayer/Health.Game = self.get_path()

func instance_n(number : int) -> void:
	for n in range(number):
		var spawn_idx = randi() % ((
			self.get_node(self.n_r_spawn_points_nodepaths).get_child_count() +
			self.get_node(self.n_r_paths_nodepaths).get_child_count()
		) / 2)
		
		var new_n = self.N_scene.instance()
		new_n.name = new_n.name + String(n)
		new_n.position = self.get_node(self.n_r_spawn_points_nodepaths).get_child(spawn_idx).position
		new_n.Player = $Player
		new_n.path2D = self.get_node(self.n_r_paths_nodepaths).get_child(spawn_idx).get_path()
		
		yield(self.get_tree().create_timer(self.enemy_spawn_cooldown), "timeout")
		
		$Enemies/N.add_child(new_n)

func instance_r(number : int) -> void:
	for n in range(number):
		var spawn_idx = randi() % ((
			self.get_node(self.n_r_spawn_points_nodepaths).get_child_count() +
			self.get_node(self.n_r_paths_nodepaths).get_child_count()
		) / 2)
		
		var new_r = self.R_scene.instance()
		new_r.name = new_r.name + String(n)
		new_r.position = self.get_node(self.n_r_spawn_points_nodepaths).get_child(spawn_idx).position
		new_r.Player = $Player
		new_r.path2D = self.get_node(self.n_r_paths_nodepaths).get_child(spawn_idx).get_path()
		
		yield(self.get_tree().create_timer(self.enemy_spawn_cooldown), "timeout")
		
		$Enemies/R.add_child(new_r)

func instance_c(number : int) -> void:
	pass

func _physics_process(delta : float) -> void:
	pass

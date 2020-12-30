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

var total_enemies = 0

var level = 1

func enemies_from_level(level : int) -> Dictionary:
	var levels_start_at = 1
	
	if level ==  5: return { "N": 0, "R": 0, "C":  8 }
	if level == 10: return { "N": 0, "R": 0, "C": 16 }
	
	if level <= 10:
		var offset = level - ( 0 + levels_start_at)
		
		return {
			"N": 2 * offset +  6,
			"R": 2 * offset +  0,
			"C": 1 * offset +  0
		}
	else:
		var offset = level - (10 + levels_start_at)
		
		return {
			"N": 2 * offset + 24,
			"R": 2 * offset + 18,
			"C": 1 * offset +  1
		}

func _ready() -> void:
	$Player/Camera2D.current = false
	
	self.set_physics_process(false)
	
	$CanvasLayer/Health.visible = false
	$CanvasLayer/Health.Game = self.get_path()

func instance_n(number : int) -> Array:
	var enemy_instances : Array = []
	
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
		
		enemy_instances.append(new_n)
	
	return enemy_instances

func instance_r(number : int) -> Array:
	var enemy_instances : Array = []
	
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
		
		enemy_instances.append(new_r)
	
	return enemy_instances

func instance_c(number : int) -> Array:
	var enemy_instances : Array = []
	
	for n in range(number):
		var spawn_idx = randi() % ((
			self.get_node(self.c_spawn_points_nodepaths).get_child_count() +
			self.get_node(self.c_paths_nodepaths).get_child_count()
		) / 2)
		
		var new_c = self.R_scene.instance()
		new_c.name = new_c.name + String(n)
		new_c.position = self.get_node(self.c_spawn_points_nodepaths).get_child(spawn_idx).position
		new_c.Player = $Player
		new_c.path2D = self.get_node(self.c_paths_nodepaths).get_child(spawn_idx).get_path()
		
		enemy_instances.append(new_c)
	
	return enemy_instances

func instance_enemies(n : int, r : int, c : int) -> void:
	var n_instances = self.instance_n(n)
	var r_instances = self.instance_r(r)
	var c_instances = self.instance_c(c)
	
	var enemy_instances : Array = n_instances + r_instances + c_instances
	randomize()
	
	enemy_instances[randi() % enemy_instances.size()]
	
	for enemy in enemy_instances:
		yield(self.get_tree().create_timer(self.enemy_spawn_cooldown), "timeout")
		
		$Enemies.add_child(enemy)
		
		enemy.connect("dead", self, "on_enemy_died")

func _physics_process(delta : float) -> void:
	pass

func on_Enemy_died() -> void:
	pass

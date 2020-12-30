extends Node2D

signal game_over

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

var enemy_instances : Array = []
var total_enemies = 0

var started_new_wave = false
var second_wave_threshold : int = 0
var finished_instancing_every_enemy = false

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
	
	$CanvasLayer/Countdown.visible = false

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
	
	self.enemy_instances = n_instances + r_instances + c_instances
	
	self.total_enemies = self.enemy_instances.size()
	
	randomize()
	
	self.enemy_instances[randi() % self.enemy_instances.size()]
	
	var half_of_enemies = int(ceil(float(self.enemy_instances.size()) / 2))
	
	# split array into 2
	
	var enemies_to_instance := []
	for i in range(0, half_of_enemies): enemies_to_instance.append(self.enemy_instances[i])
	
	var enemies_for_later := []
	for i in range(half_of_enemies + 1, self.enemy_instances.size()): enemies_for_later.append(self.enemy_instances[i])
	
	# actually instance them
	
	for i in range(enemies_to_instance.size()):
		yield(self.get_tree().create_timer(self.enemy_spawn_cooldown), "timeout")
		
		$Enemies.add_child(enemies_to_instance[i])
		
		enemies_to_instance[i].connect("dead", self, "on_enemy_died")
	
	self.enemy_instances = enemies_for_later
	self.second_wave_threshold = self.enemy_instances.size()

func start_level(level : int):
	$CanvasLayer/Countdown.visible = true
	$CanvasLayer/Countdown/AnimationPlayer.play("Countdown")
	yield($CanvasLayer/Countdown/AnimationPlayer, "animation_finished")
	$CanvasLayer/Countdown.visible = false
	
	var planned_enemies = self.enemies_from_level(level)
	self.instance_enemies(
		planned_enemies.N,
		planned_enemies.R,
		planned_enemies.C
	)

func _physics_process(delta : float) -> void:
	pass

func second_wave() -> void:
	for i in range(self.enemy_instances.size()):
		yield(self.get_tree().create_timer(self.enemy_spawn_cooldown), "timeout")
		
		$Enemies.add_child(self.enemy_instances[i])
		
		self.enemy_instances[i].connect("dead", self, "on_enemy_died")
	
	self.enemy_instances = []
	
	self.finished_instancing_every_enemy = true
	
	self.level += 1
	self.start_level(self.level)

func _on_10SecTimer_timeout():
	if not self.started_new_wave:
		self.started_new_wave = true
		
		self.second_wave()

func _on_Player_dead():
	self.emit_signal("game_over", self.level)

func on_Enemy_died() -> void:
	self.total_enemies -= 1
	
	if not self.started_new_wave:
		if self.total_enemies <= self.second_wave_threshold:
			self.started_new_wave = true
			
			self.second_wave()
	
	if self.total_enemies == 0:
		self.get_node("Timers/10SecTimer").start(10)

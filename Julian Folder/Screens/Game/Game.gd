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
export (float) var second_wave_timeout : float = 10.0
export (float) var in_between_levels_timeout : float = 1.5

export (float) var n_ratio = 0.55
export (float) var r_ratio = 0.4
export (float) var c_ratio = 0.05

var ns_to_spawn : int = 0
var rs_to_spawn : int = 0
var cs_to_spawn : int = 0

var enemy_instances : Array = []
var R_instances_in_game : Array = []
var total_enemies = 0

var started_new_wave = false
var second_wave_threshold : int = 0
var finished_instancing_every_enemy = false

var level = 1

func enemies_from_level(level : int) -> Dictionary:
	var levels_start_at = 1
	
	var total_enemies : int = int(floor(15 * (log(level+3)/log(2)) + cos(level) * 7 * log(level)))
	
	var total_N : int = total_enemies * self.n_ratio
	var total_R : int = total_enemies * self.r_ratio
	var total_C : int = clamp(total_enemies * self.c_ratio, 0, 5)
	
	return {
		"N": total_N,
		"R": total_R,
		"C": total_C,
		"total": total_N + total_R + total_C
	}

func _ready() -> void:
	$Player/Camera2D.current = false
	
	self.set_physics_process(false)
	
	$CanvasLayer/Health.visible = false
	$CanvasLayer/Health.Game = self.get_path()
	
	$CanvasLayer/Countdown.visible = false

func instance_n(number : int) -> Array:
	var enemy_instances : Array = []
	
	if number > 0:
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
	
	if number > 0:
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
	
	if number > 0:
		for n in range(number):
			
			var spawn_idx = randi() % ((
				self.get_node(self.c_spawn_point_nodepaths).get_child_count() +
				self.get_node(self.c_paths_nodepaths).get_child_count()
			) / 2)
			
			var new_c = self.C_scene.instance()
			new_c.name = new_c.name + String(n)
			new_c.position = self.get_node(self.c_spawn_point_nodepaths).get_child(spawn_idx).position
			new_c.Player = $Player
			new_c.path2D = self.get_node(self.c_paths_nodepaths).get_child(spawn_idx).get_path()
			
			match spawn_idx:
				0: new_c.direction = Vector2.RIGHT
				1: new_c.direction = Vector2.DOWN
				2: new_c.direction = Vector2.LEFT
				3: new_c.direction = Vector2.UP
			
			enemy_instances.append(new_c)
	
	return enemy_instances

func instance_enemies(n : int, r : int, c : int) -> void:
	var n_instances = self.instance_n(n)
	var r_instances = self.instance_r(r)
	var c_instances = self.instance_c(c)
	
	self.enemy_instances = n_instances + r_instances + c_instances
	
	self.R_instances_in_game = r_instances
	
	for r_instance in self.R_instances_in_game:
		for r_other_instance in self.R_instances_in_game:
			r_instance.R_instances.append(r_other_instance)
	
	self.total_enemies = self.enemy_instances.size()
	$CanvasLayer/Enemies/Label.text = str(self.total_enemies)
	
	randomize()
	self.enemy_instances.shuffle()
	
	for i in range(self.enemy_instances.size()):
		$Timers/EnemySpawnCooldown.start(self.enemy_spawn_cooldown)
		yield($Timers/EnemySpawnCooldown, "timeout")
		
		$Enemies.add_child(self.enemy_instances[i])
		
		self.enemy_instances[i].connect("dead", self, "on_enemy_died")

func start_level(level : int):
	$CanvasLayer/Countdown.visible = true
	$CanvasLayer/Countdown/AnimationPlayer.play("Countdown")
	yield($CanvasLayer/Countdown/AnimationPlayer, "animation_finished")
	$CanvasLayer/Countdown.visible = false
	
	$Player.reset()
	
	var planned_enemies = self.enemies_from_level(level)
	if planned_enemies.total > 0:
		self.instance_enemies(
			planned_enemies.N,
			planned_enemies.R,
			planned_enemies.C
		)
		
	else:
		self.next_level()

func next_level():
	self.level += 1
	
	$Timers/InBetweenLevelsTimer.start(self.in_between_levels_timeout)
	yield($Timers/InBetweenLevelsTimer, "timeout")
	
	self.start_level(self.level)

func _physics_process(delta : float) -> void:
	pass

func _on_SecondWaveTimer_timeout():
	pass

func _on_Player_dead():
	self.emit_signal("game_over", self.level)

func on_enemy_died(enemy_name : String) -> void:
	self.total_enemies -= 1
	$CanvasLayer/Enemies/Label.text = str(self.total_enemies)
	
	if name.begins_with("R"):
		for r_enemy in self.R_instances_in_game.size():
			if r_enemy.name != enemy_name:
				for r_other_instance in self.R_instances_in_game:
					r_enemy.R_instances.apend(r_other_instance)
	
	if total_enemies <= 0:
		self.next_level()

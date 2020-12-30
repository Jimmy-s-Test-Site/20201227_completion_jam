extends Node2D

signal can_heal
signal changed_health

export (PackedScene) var N_resource
export (PackedScene) var R_resource
export (PackedScene) var C_resource

export (NodePath) var c_spawn_point_nodepaths
export (NodePath) var c_paths_nodepaths
export (NodePath) var n_r_spawn_points_nodepaths
export (NodePath) var n_r_paths_nodepaths

export (int) var initial_ns_to_spawn : int = 10
export (int) var initial_rs_to_spawn : int =  0
export (int) var initial_cs_to_spawn : int =  0

var N_scene
var R_scene
var C_scene

var ns_to_spawn : int = 0
var rs_to_spawn : int = 0
var cs_to_spawn : int = 0

var level = 1

func _ready() -> void:
	$Player/Camera2D.current = false
	
	self.set_physics_process(false)
	
	$CanvasLayer/Health.visible = false
	$CanvasLayer/Health.Game = self.get_path()
	
	var new_n = self.N_resource.instance()
	new_n.name = "BobRoss"
	new_n.position = self.get_node(self.n_r_spawn_points_nodepaths).get_child(0).position
	new_n.position = $Player.position + Vector2.LEFT * 10
	new_n.path2D = self.get_node(self.n_r_paths_nodepaths).get_child(0).get_path()
	
	print(new_n.path2D)
	print(new_n.position)
	
	self.add_child(new_n)

func _physics_process(delta : float) -> void:
	pass



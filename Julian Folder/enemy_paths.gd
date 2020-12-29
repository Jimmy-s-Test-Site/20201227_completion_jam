extends Node2D

func _ready():
	$N.Player = $Player
	$N.path2D = $Path2D.get_path()
	$N.path_points = $Path2D.curve.get_baked_points()

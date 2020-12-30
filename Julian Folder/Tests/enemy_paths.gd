extends Node2D

func _ready():
	$R.Player = $Player
	$R.path2D = $Path2D.get_path()

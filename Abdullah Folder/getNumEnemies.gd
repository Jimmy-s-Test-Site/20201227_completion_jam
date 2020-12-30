extends Node




func getNum(level:int):
	var n = 6
	var r = 0
	var c = 0
	var enemies = {}
	
	if level < 11:
		for x in range(1,level):
			n += 4
			r += 2
		if level == 5:
			n = 0
			r = 0
			c = 8
		elif level == 10:
			n = 0
			r = 0
			c = 16
		enemies = { "N": 6, "R": 0, "C": 0 }
	else:
		level -= 10
		n = 2*(level)+24
		r = 2*(level)+18
		c = level + 1
		enemies = { "N": 6, "R": 0, "C": 0 }
	return enemies
	

func _ready():
	pass # Replace with function body.

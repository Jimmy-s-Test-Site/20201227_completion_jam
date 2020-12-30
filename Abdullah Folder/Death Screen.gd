extends Control



func setScore(score:int):
	Label.text = "You're out of \nluck punk \nOnly lasted: " + str(score) + "level(s)"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends Control

signal startAgain

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("continue"):
		self.emit_signal("startAgain")
		self.visible = false
		self.set_physics_process(false)




func setScore(score:int):
	Label.text = "You're out of \nluck punk \nOnly lasted: " + str(score) + "level(s)"


func _ready():
	$Game/Player.connect("dead",self, "_on_Player_dead")


func _on_Player_dead():
	self.visible = true

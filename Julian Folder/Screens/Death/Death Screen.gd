extends Control

signal startAgain

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("continue"):
		self.emit_signal("startAgain")
		self.visible = false
		self.set_physics_process(false)

func setScore(score : int):
	$Label.text = str("You're out of \nluck punk \nOnly lasted:\n", score, " level(s)")

func _ready():
	pass
	#self.get_parent().get_parent().get_node("Game/Player").connect("dead", self, "_on_Player_dead")

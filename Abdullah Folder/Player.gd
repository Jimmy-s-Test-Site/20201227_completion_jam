extends KinematicBody2D

signal playerDeath
signal killedEnemy
signal newHp


export (int) var speed = 8000
export (int) var rotationSpeed = 5
var min_max = [5, 15]


var dead = false


export (int) var maxHealth = 10
var healthRemaining = maxHealth
var isHealAvailable = true;




var rng = RandomNumberGenerator.new()

var input = {
	"up" : false,
	"down" : false,
	"left" : false,
	"right" : false,
	"attack" : false,
	"heal" : false
 }

var motion = Vector2()

func _physics_process(delta):
	if not dead:
		getInput()
		inputToMotion(delta)
		healing()
	
	
	

func getInput() -> void:
	self.input.up = Input.is_action_pressed("ui_up")
	self.input.right = Input.is_action_pressed("ui_right")
	self.input.left = Input.is_action_pressed("ui_left")
	self.input.down = Input.is_action_pressed("ui_down")
	self.input.attack = Input.is_action_just_pressed("attack")
	self.input.heal = Input.is_action_just_pressed("heal")
	

func inputToMotion(delta:float) -> void:
	self.rotation += self.rotationSpeed * delta * (int(self.input.right) - int(self.input.left))
	var verticalAxis = int(self.input.down) - int(self.input.up)
	
	self.motion.x = -sin(self.rotation) * verticalAxis
	self.motion.y = cos(self.rotation) * verticalAxis
	self.motion = self.motion.normalized() * self.speed * delta
	self.motion = move_and_slide(self.motion, Vector2.ZERO)




func healing():
	if self.input.heal and self.isHealAvailable:
		print("yes heal")
		self.healthRemaining += 4
		
		if self.healthRemaining > self.maxHealth: 
			self.healthRemaining = self.maxHealth
		
		self.isHealAvailable = false
		$Timer.wait_time = rng.randi_range(self.min_max[0],self.min_max[1])
		$Timer.start()





func attack():
	pass


func damageReceived():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if ["N", "R", "C"].has(collision.collider.name):
			match collision.collider.name:
				"N":healthRemaining -= 1
				"R":healthRemaining -= 1
				"C":healthRemaining -= 4
			if healthRemaining < 0:
				emit_signal("playerDeath")
				healthRemaining = 0
				dead = true
			emit_signal("newHp",healthRemaining)
	


func animationManager():
	pass






func _ready():
	rng.randomize()
	$Timer.wait_time = 0.0
	$Timer.start()


func _on_Timer_timeout(): self.isHealAvailable = true

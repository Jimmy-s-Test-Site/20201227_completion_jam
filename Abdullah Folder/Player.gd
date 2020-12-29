extends KinematicBody2D


#putting a comment for fun

signal playerDeath
signal attack
#signal hit
signal newHp

var rng = RandomNumberGenerator.new()

export (int) var speed = 8000
export (int) var rotationSpeed = 5
var min_max = [5, 15]

var dead = false
var attackReady = true
var receivingAttack = false
var animationIsFinished = true

export (int) var maxHealth = 10
var healthRemaining = maxHealth
var isHealAvailable = true;

var input = {
	"up"     : false,
	"down"   : false,
	"left"   : false,
	"right"  : false,
	"attack" : false,
	"heal"   : false
 }

var motion = Vector2()

func _physics_process(delta):
	if not dead:
		getInput()
		inputToMotion(delta)
		healing()
		attack()
		animationManager()
	
	
	

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
	if self.input.attack:
		$Area2D/AttackRange.disabled = false
		#emit_signal("hit")
		$AttackTimer.wait_time = 0.5
		$AttackTimer.start()
	
	

func receivedDamage():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if (
			["N", "R", "C"].has(collision.collider.name) or \
			["N", "R", "C"].has(collision.collider.get_parent().name)
		):
			# self.healthRemaining -= collision.collider.attack
			
			collision.collider.connect("attack", self, "on_enemy_attack")
			
			if self.receivingAttack:
				match collision.collider.name:
					"N": self.healthRemaining -= 1
					"R": self.healthRemaining -= 1
					"C": self.healthRemaining -= 4
				
				if healthRemaining < 0:
					emit_signal("playerDeath")
					healthRemaining = 0
					dead = true
					$deadSprite.visible = true
				emit_signal("newHp",healthRemaining)
	
func on_enemy_attack():
	self.receivingAttack = true

func animationManager():
	if self.animationIsFinished:
		if self.input.attack : $AnimationPlayer.play("Attack")
		elif self.input.up or self.input.down or self.input.left or self.input.right:
			$AnimationPlayer.play("Walking")
		elif self.input.heal : $AnimationPlayer.play("Heal")
		else:
			$AnimationPlayer.play("Walking")
		self.animationIsFinished = false






func _ready():
	rng.randomize()
	$Timer.wait_time = 0.1
	$Timer.start()
	$AttackTimer.wait_time = 0.5
	$AttackTimer.start()


func _on_Timer_timeout(): self.isHealAvailable = true




func _on_AttackTimer_timeout():
	$Area2D/AttackRange.disabled = true
	attackReady = true


func _on_Area2D_body_entered(_body):
	emit_signal("attack")


func _on_AnimationPlayer_animation_finished(anim_name):
	self.animationIsFinished = true

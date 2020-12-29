extends KinematicBody2D

signal dead
signal attack
signal new_hp

var rng = RandomNumberGenerator.new()

export (int) var maxHealth = 10
export (int) var hp_recovered_on_heal : int = 4
export (int) var speed : int = 8000
export (int) var rotationSpeed : int = 5

onready var animation_tree : AnimationTree = $AnimationTree
onready var animation_mode : AnimationNodeStateMachinePlayback = self.animation_tree.get("parameters/playback")

var min_max = [5, 15]

var dead = false
var attackReady = true
var receivingAttack = false
var animationIsFinished = true

var healthRemaining = maxHealth
var isHealAvailable = true;

var input_vector := Vector2.ZERO

var input = {
	"up"     : false,
	"down"   : false,
	"left"   : false,
	"right"  : false,
	"attack" : false,
	"heal"   : false
 }

var motion = Vector2.ZERO

func _ready() -> void:
	
	self.rng.randomize()
	$Timer.wait_time = 0.1
	$Timer.start()
	$AttackTimer.wait_time = 0.5
	$AttackTimer.start()

func _physics_process(delta):
	if not self.dead:
		self.getInput()
		self.inputToMotion(delta)
		var healed = self.healing()
		self.attack()
		self.animationManager(healed)

func getInput() -> void:
	self.input.up = Input.is_action_pressed("ui_up")
	self.input.right = Input.is_action_pressed("ui_right")
	self.input.left = Input.is_action_pressed("ui_left")
	self.input.down = Input.is_action_pressed("ui_down")
	
	self.input.attack = Input.is_action_just_pressed("attack")
	self.input.heal = Input.is_action_just_pressed("heal")
	
	self.input_vector.x = int(self.input.right) - int(self.input.left)
	self.input_vector.y = int(self.input.down) - int(self.input.up)

func inputToMotion(delta : float) -> void:
	self.rotation += self.rotationSpeed * delta * self.input_vector.x
	var verticalAxis = self.input_vector.y
	
	self.motion = Vector2(
		-sin(self.rotation),
		cos(self.rotation)
	) * verticalAxis
	
	self.motion = self.motion.normalized() * self.speed * delta
	self.motion = self.move_and_slide(self.motion, Vector2.ZERO)

func healing() -> bool:
	if self.input.heal and self.isHealAvailable:
		self.healthRemaining += self.hp_recovered_on_heal
		
		if self.healthRemaining > self.maxHealth: 
			self.healthRemaining = self.maxHealth
		
		self.isHealAvailable = false
		$Timer.start(self.rng.randi_range(self.min_max[0], self.min_max[1]))
		return true
	
	return false

func attack() -> void:
	if self.input.attack:
		$Area2D/AttackRange.disabled = false
		$AttackTimer.start(0.5)

func receivedDamage() -> void:
	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		
		if ["N", "R", "C"].has(collision.collider.get_parent().name):
			collision.collider.connect("attack", self, "on_enemy_attack")
			
			if self.receivingAttack:
				match collision.collider.name:
					"N": self.healthRemaining -= 1
					"R": self.healthRemaining -= 1
					"C": self.healthRemaining -= 4
				
				if self.healthRemaining < 0:
					self.emit_signal("dead")
					self.healthRemaining = 0
					self.dead = true
					$aliveSprite.visible = false
					$deadSprite.visible = true
				
				self.emit_signal("new_hp", self.healthRemaining)
	
func on_enemy_attack() -> void:
	self.receivingAttack = true

func animationManager(healed : bool) -> void:
	if self.input.attack:
		self.animation_mode.travel("Attack")
	elif self.input.heal and healed:
		self.animation_mode.travel("Heal")
	elif self.input_vector != Vector2.ZERO:
		self.animation_mode.travel("Walking")
	else:
		self.animation_mode.travel("Idle")

func _on_Timer_timeout() -> void: self.isHealAvailable = true

func _on_AttackTimer_timeout() -> void:
	$Area2D/AttackRange.disabled = true
	self.attackReady = true

func _on_Area2D_body_entered(_body : Node) -> void:
	self.emit_signal("attack")

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	self.animationIsFinished = true

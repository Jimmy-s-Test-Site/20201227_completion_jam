extends KinematicBody2D

signal dead
signal attack
signal new_hp

export (int, 1, 10) var max_health = 10
export (int) var hp_recovered_on_heal : int = 4
export (int) var speed : int = 8000
export (int) var rotation_speed : int = 5

export (float) var attack_cooldown : float = 0.5

export (Dictionary) var heal_range : Dictionary = {
	"mini": 5,
	"maxi": 15
}

onready var animation_tree : AnimationTree = $AnimationTree
onready var animation_mode : AnimationNodeStateMachinePlayback = self.animation_tree.get("parameters/playback")

onready var health = self.max_health

var rng = RandomNumberGenerator.new()

var alive            := true
var healing          := false
var healed           := false
var attacking        := false
var moving           := false
var receiving_damage := false

var can_heal := true
var can_attack := false

var input = {
	"vector" : Vector2.ZERO,
	"attack" : false,
	"heal"   : false
}

var motion = Vector2.ZERO

func _ready() -> void:
	self.reset()

func _physics_process(delta):
	if self.alive:
		self.input_manager()
		self.motion_manager(delta)
		self.receive_damage()
		self.attack_manager()
		self.health_manager()
		self.death_manager()
		self.animation_manager()
		self.audio_manager()

func input_manager() -> void:
	var left  = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var up    = Input.is_action_pressed("ui_up")
	var down  = Input.is_action_pressed("ui_down")
	
	self.input.vector.x = int(right) - int(left)
	self.input.vector.y = int(down)  - int(up)
	
	self.input.attack = Input.is_action_just_pressed("attack")
	self.input.heal   = Input.is_action_just_pressed("heal")

func motion_manager(delta : float) -> void:
	self.rotation += self.rotation_speed * delta * self.input.vector.x
	var vertical_axis = self.input.vector.y
	
	self.motion = Vector2(
		-sin(self.rotation),
		cos(self.rotation)
	) * vertical_axis
	
	self.motion = self.motion.normalized() * self.speed * delta
	self.motion = self.move_and_slide(self.motion, Vector2.ZERO)
	
	self.moving = self.input.vector != Vector2.ZERO

func receive_damage() -> void:
	self.receiving_damage = false
	
	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		var enemy = collision.collider
		
		var n_collision = enemy.name.begins_with("N")
		var r_collision = enemy.name.begins_with("R")
		var c_collision = enemy.name.begins_with("C")
		var enemy_collision = n_collision or r_collision or c_collision
		
		if enemy_collision and enemy.can_attack:
			self.health -= enemy.attack_amount
			
			if self.health < 0:
				self.health = 0
			else:
				self.emit_signal("new_hp", self.health)
				
				self.receiving_damage = true

func attack_manager() -> void:
	if self.input.attack and self.can_attack:
		$AttackTimer.start(self.attack_cooldown)
		$Area2D/AttackRange.disabled = false
		
		self.emit_signal("attack")
		
		self.attacking = true
		self.can_attack = false

func health_manager() -> void:
	if self.input.heal and self.can_heal:
		self.health += self.hp_recovered_on_heal
		
		$HealTimer.start(self.rng.randi_range(self.heal_range.mini, self.heal_range.maxi))
		
		if self.health > self.max_health:
			self.health = self.max_health
		
		self.emit_signal("new_hp", self.health)
		
		self.healing = true
		self.can_heal = false

func death_manager() -> void:
	if self.health == 0:
		self.emit_signal("dead")
		
		self.alive = false

func animation_manager() -> void:
	if self.alive:
		if self.attacking:
			$AnimationPlayer.play("Attack")
		elif self.healing:
			$AnimationPlayer.play("Heal")
		elif self.moving:
			$AnimationPlayer.play("Walking")
		else:
			$AnimationPlayer.play("Idle")
	else:
		$AnimationPlayer.play("Dead")

func audio_manager() -> void:
	if self.alive:
		if self.receiving_damage:
			if not $SFX/GotHitSound.playing:
				$SFX/GotHitSound.play()

func _on_HealTimer_timeout() -> void:
	self.can_heal = true

func _on_AttackTimer_timeout() -> void:
	self.can_attack = true

func _on_Area2D_body_entered(_body : Node) -> void:
	pass

func _on_AnimationPlayer_animation_finished(anim_name : String) -> void:
	if self.attacking:
		self.attacking = false
	
	if self.healing:
		self.healing = false

func reset():
	self.rng.randomize()
	
	#self.animation_mode.travel("idle")
	
	$AttackTimer.start(self.attack_cooldown)


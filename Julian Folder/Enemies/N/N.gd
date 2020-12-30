extends KinematicBody2D

signal in_game
signal attack
signal dead

export (int) var health : int = 1
export (int) var attack : int = 1
export (int) var movement_speed : int = 3500
export (int) var path_movement_speed : int = 3500

export (float) var rotation_speed : float = 5.0
export (float) var attack_cooldown_time : float = 1.0
export (float) var despawn_time : float = 1.5

var path2D # : NodePath
var is_path2D_loaded := false

var alive := true
var attacking := false

var Player : KinematicBody2D
var player_is_alive := true
var player_attacked := false

var following_path := true
var path_points : PoolVector2Array
var prev_path_index : int = 0
var curr_path_index : int = 0

func player_exists() -> bool: return self.Player != null

func _ready() -> void:
	$AttackTimer.start(self.attack_cooldown_time)
	
	$AnimationPlayer.play("Walk")

func needs_to_load_path2D() -> bool:
	return not self.is_path2D_loaded and self.path2D

func load_path2D() -> void:
	self.path_points = self.get_node(self.path2D).curve.get_baked_points()
	
	self.is_path2D_loaded = true

func _physics_process(delta : float) -> void:
	if self.needs_to_load_path2D(): self.load_path2D()
	
	self.movement_manager(delta)
	self.receive_damage()
	self.attack_manager()
	self.death_manager()
	self.animation_manager()

func movement_manager(delta : float) -> void:
	if self.is_path2D_loaded:
		if self.should_follow_path():
			self.emit_signal("in_game")
			self.following_path = false
		
		if self.following_path:
			self.follow_path(delta)
		else:
			self.move(delta)
	else:
		self.stay_still()

func stay_still() -> void: pass

func should_follow_path() -> bool:
	var on_last_index := self.prev_path_index != 0 and self.curr_path_index == 0
	return self.following_path and on_last_index

func follow_path(delta : float) -> void:
	if self.path2D == null:
		return
	
	var target = self.path_points[self.curr_path_index]
	
	if self.position.distance_to(target) < 1:
		self.prev_path_index = self.curr_path_index
		self.curr_path_index = wrapi(self.curr_path_index + 1, 0, self.path_points.size())
		target = self.path_points[self.curr_path_index]
	
	var movement = self.position.direction_to(target).normalized() * path_movement_speed * delta
	self.move_and_slide(movement)

func move(delta : float) -> void:
	var objective : Vector2 = self.Player.global_position
	
	# TODO:
	# make AI only move forwards, and rotate at set speed
	
	self.rotation = self.global_position.direction_to(objective).angle() + (PI/2)
	
	var movement_direction = self.global_position.direction_to(objective)
	var movement = movement_direction * self.movement_speed * delta
	
	self.move_and_slide(movement)

func receive_damage() -> void:
	for i in self.get_slide_count():
		var collision = self.get_slide_collision(i)
		
		if collision.collider.name == "Player":
			if not collision.collider.is_connected("attack", self, "on_Player_attack"):
				collision.collider.connect("attack", self, "on_Player_attack")
			
			$SFX/GotHitSound.play()
			
			if self.player_attacked:
				self.health -= 1
				if self.health < 0: self.health = 0

func attack_manager() -> void:
	if self.attacking and $AttackTimer.time_left == 0:
		self.emit_signal("attack")
		$AttackTimer.start(self.attack_cooldown_time)
		self.attacking = false

func death_manager() -> void:
	if self.health == 0:
		self.emit_signal("dead")
		
		$AttackArea.set_process(false)
		$AttackArea.set_physics_process(false)
		
		$DespawnTimer.start(self.despawn_time)
		$SFX/DyingSound.play()
		self.alive = false

func animation_manager() -> void:
	if not self.alive:
		$AnimationPlayer.play("Dead")
	elif self.attacking:
		$AnimationPlayer.play("Attack")
	else:
		$AnimationPlayer.play("Walk")

func _on_AttackArea_body_entered(body) -> void:
	self.attacking = true

func _on_DespawnTimer_timeout():
	self.queue_free()

func on_Player_attack() -> void:
	self.player_attacked = true

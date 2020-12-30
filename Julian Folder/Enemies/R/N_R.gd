extends KinematicBody2D

signal in_game
signal attack
signal dead

export (int)   var health : int = 1
export (int)   var attack_amount : int = 1
export (int)   var movement_speed : int = 3500
export (int)   var path_movement_speed : int = 3500

export (float) var rotation_speed : float = 5.0
export (float) var attack_cooldown_time : float = 1.0
export (float) var despawn_time : float = 1.5

var path2D
var is_path2D_loaded := false

var alive := true
var attacking := false
var receiving_damage := false
var can_attack := true
var is_player_in_attacking_range := false
var player_is_attacking := false

var Player : KinematicBody2D
var player_is_alive := true

var following_path := true
var path_points : PoolVector2Array
var prev_path_index : int = 0
var curr_path_index : int = 0

var R_positions : PoolVector2Array

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
	if self.alive:
		if self.needs_to_load_path2D(): self.load_path2D()
		
		self.movement_manager(delta)
		self.receive_damage()
		self.attack_manager()
		self.death_manager()
		self.animation_manager()

func movement_manager(delta : float) -> void:
	if self.should_follow_path():
		self.emit_signal("in_game")
		self.following_path = false
	
	if self.following_path:
		self.follow_path(delta)
	else:
		self.move(delta)

func should_follow_path() -> bool:
	var on_last_index := self.prev_path_index != 0 and self.curr_path_index == 0
	return self.following_path and on_last_index

func follow_path(delta : float) -> void:
	if not self.path2D: return
	
	var target = self.path_points[self.curr_path_index]
	
	if self.position.distance_to(target) < 1:
		self.prev_path_index = self.curr_path_index
		self.curr_path_index = wrapi(self.curr_path_index + 1, 0, self.path_points.size())
		target = self.path_points[self.curr_path_index]
	
	var movement = self.position.direction_to(target).normalized() * path_movement_speed * delta
	self.move_and_slide(movement)

func move(delta : float) -> void:
	var Rs_and_player_mean_position := self.Player.global_position
	for i in self.R_positions.size(): Rs_and_player_mean_position += self.R_positions[i]
	Rs_and_player_mean_position /= 1 + self.R_positions.size()
	
	var objective : Vector2 = self.Player.global_position
	
	# TODO:
	# make AI only move forwards, and rotate at set speed
	
	self.rotation = self.global_position.direction_to(objective).angle() + (PI/2)
	
	var movement_direction = self.global_position.direction_to(objective)
	var movement = movement_direction * self.movement_speed * delta
	
	self.move_and_slide(movement)

func receive_damage() -> void:
	self.receiving_damage = false
	
	for area in $BodyArea.get_overlapping_areas():
		if area.get_parent().name == "Player":
			if not area.get_parent().is_connected("attack", self, "on_player_attack"):
				area.get_parent().connect("attack", self, "on_player_attack")
			
			if self.player_is_attacking:
				self.health -= 1
				
				if self.health < 0:
					self.health = 0
				else:
					self.receiving_damage = true
				
				self.player_is_attacking = false

func attack_manager() -> void:
	if self.is_player_in_attacking_range and self.can_attack:
		$AttackTimer.start(self.attack_cooldown_time)
		
		self.emit_signal("attack", self)
		
		self.can_attack = false
		self.attacking = true

func death_manager() -> void:
	if self.health == 0:
		self.emit_signal("dead")
		
		$AttackArea.set_process(false)
		$AttackArea.set_physics_process(false)
		
		$DespawnTimer.start(self.despawn_time)
		
		self.alive = false

func animation_manager() -> void:
	if self.alive:
		if self.attacking:
			$AnimationPlayer.play("Attack")
		else:
			$AnimationPlayer.play("Walk")
	else:
		$AnimationPlayer.play("Dead")
		$SFX/DyingSound.play()


func set_is_player_in_attacking_range(body : String, value : bool) -> void:
	if body == "Player":
		self.is_player_in_attacking_range = value

func _on_AttackArea_body_entered(body : Node) -> void:
	self.set_is_player_in_attacking_range(body.name, true)

func _on_AttackArea_body_exited(body : Node) -> void:
	self.set_is_player_in_attacking_range(body.name, false)

func _on_DespawnTimer_timeout() -> void:
	pass
	#self.queue_free()

func _on_AttackTimer_timeout() -> void:
	self.can_attack = true

func _on_AnimationPlayer_animation_finished(_anim_name : String) -> void:
	if self.attacking:
		self.attacking = false

func on_player_attack() -> void:
	self.player_is_attacking = true

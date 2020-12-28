extends KinematicBody2D

signal in_game
signal attack

export (NodePath) var path2D

export (int)   var health : int = 1
export (int)   var attack : int = 1
export (int)   var movement_speed : int = 3500
export (int)   var path_movement_speed : int = 3500

export (float) var rotation_speed
export (float) var attack_cooldown_time : float = 1.0

var attacking = false

var screen_center := Vector2.ZERO

var Player : KinematicBody2D
var player_is_alive := true
var player_attacked := false

var following_path := true
var path_points : PoolVector2Array
var prev_path_index : int = 0
var curr_path_index : int = 0

func player_exists() -> bool: return self.Player != null

func _ready() -> void:
	if self.path2D:
		self.path_points = self.get_node(self.path2D).curve.get_baked_points()
	
	$AttackTimer.start(self.attack_cooldown_time)

func _physics_process(delta : float) -> void:
	self.movement_manager(delta)
	self.receive_damage()
	self.attack_manager()
	self.death_manager()

func movement_manager(delta : float) -> void:
	if self.should_follow_path(): self.following_path = false
	
	if self.following_path: self.follow_path(delta)
	else: self.move(delta)

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
	move_and_slide(movement)

func move(delta : float) -> void:
	var objective := self.Player.global_position if   \
		self.player_exists() and self.player_is_alive \
		else self.screen_center
	
	# TODO:
	# make AI only move forwards, and rotate at set speed
	
	self.rotation = self.global_position.direction_to(objective).angle() + (PI/2)
	
	var movement_direction = self.global_position.direction_to(objective)
	var movement = movement_direction * self.movement_speed * delta
	
	self.move_and_slide(movement)

func receive_damage() -> void:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if collision.collider.name == "Player":
			collision.collider.connect("attack", self, "on_Player_attack")
			
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
		self.queue_free()

func _on_AttackArea_body_entered(body) -> void:
	self.attacking = true

func on_Player_attack() -> void:
	self.player_attacked = true

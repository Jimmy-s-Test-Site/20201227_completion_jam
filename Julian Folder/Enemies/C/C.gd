extends KinematicBody2D

signal in_game
signal dead

export (Vector2) var direction := Vector2.UP

export (int)     var health : int = 4
export (int)     var attack : int = 4
export (int)     var max_path_movement_speed : int = 3500

onready var total_health = self.health


onready var path_movement_speed : int = self.max_path_movement_speed

var path2D
var is_path2D_loaded := false

var attacking := false
var alive := true
var receiving_damage := false
var player_is_attacking := false

var Player : KinematicBody2D
var player_is_alive := true

var following_path := true
var path_points : PoolVector2Array
var prev_path_index : int = 0
var curr_path_index : int = 0

func player_exists() -> bool: return self.Player != null

func _ready() -> void:
	pass

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
	if not $SFX/Siren.playing:
		$SFX/Siren.play()
	self.follow_path(delta)

func follow_path(delta : float) -> void:
	if not self.path2D: return
	
	var target = self.path_points[self.curr_path_index]
	
	if self.position.distance_to(target) < 1:
		self.prev_path_index = self.curr_path_index
		self.curr_path_index = wrapi(self.curr_path_index + 1, 0, self.path_points.size())
		target = self.path_points[self.curr_path_index]
	
	var movement = self.position.direction_to(target).normalized() * path_movement_speed * delta
	self.move_and_slide(movement)

func receive_damage() -> void:
	self.receiving_damage = false
	
	for area in $BodyArea.get_overlapping_areas():
		if area.get_parent().name == "Player" or area.get_parent().name.begins_with("C"):
			if not area.get_parent().is_connected("attack", self, "on_player_attack"):
				area.get_parent().connect("attack", self, "on_player_attack")
			
			if self.player_is_attacking:
				self.health -= 1
				
				if self.health < 0:
					self.health = 0
				else:
					self.receiving_damage = true
					
					self.path_movement_speed = (self.health / self.total_health) * self.max_path_movement_speed
				
				self.player_is_attacking = false
	
	# TODO: set speed to (health / total health) * speed

func attack_manager() -> void:
	if self.attacking:
		self.emit_signal("attack", self)
		self.attacking = false

func death_manager() -> void:
	var on_last_index := self.prev_path_index != 0 and self.curr_path_index == 0
	
	if self.health == 0 or on_last_index and self.alive:
		self.alive = false
		self.emit_signal("dead")
		
		yield(self.get_tree().create_timer(1.5), "timeout")
		
		self.queue_free()

func animation_manager():
	match self.direction:
		Vector2.LEFT  : $AnimationPlayer.play("Left")
		Vector2.RIGHT : $AnimationPlayer.play("Right")
		Vector2.UP    : $AnimationPlayer.play("Up")
		Vector2.DOWN  : $AnimationPlayer.play("Down")

func _on_DespawnTimer_timeout() -> void:
	self.queue_free()

func _on_AttackArea_body_entered(body) -> void:
	self.attacking = true

func on_player_attack() -> void:
	self.player_is_attacking = true

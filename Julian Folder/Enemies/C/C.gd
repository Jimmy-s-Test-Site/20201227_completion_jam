extends KinematicBody2D

signal in_game
signal attack

export (Vector2) var direction := Vector2.UP

export (int)     var health : int = 4
export (int)     var attack : int = 4
export (int)     var path_movement_speed : int = 3500

onready var total_health = self.health

var path2D
var is_path2D_loaded := false

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
	if self.path2D:
		self.path_points = self.get_node(self.path2D).curve.get_baked_points()
	
	match self.direction:
		Vector2.LEFT  : $AnimationPlayer.play("Left")
		Vector2.RIGHT : $AnimationPlayer.play("Right")
		Vector2.UP    : $AnimationPlayer.play("Up")
		Vector2.DOWN  : $AnimationPlayer.play("Down")

func _physics_process(delta : float) -> void:
	self.movement_manager(delta)
	self.receive_damage()
	self.death_manager()

func movement_manager(delta : float) -> void:
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
	move_and_slide(movement)

func receive_damage() -> void:
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if collision.collider.name == "Player":
			if not collision.collider.is_connected("attack", self, "on_Player_attack"):
				collision.collider.connect("attack", self, "on_Player_attack")
			
			if self.player_attacked:
				self.health -= 1
				if self.health < 0: self.health = 0
	
	# TODO: set speed to (health / total health) * speed

func death_manager() -> void:
	var on_last_index := self.prev_path_index != 0 and self.curr_path_index == 0
	
	if self.health == 0 or on_last_index:
		self.queue_free()

func _on_AttackArea_body_entered(body) -> void:
	self.attacking = true

func on_Player_attack() -> void:
	self.player_attacked = true

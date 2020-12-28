extends KinematicBody2D

signal in_game

export (float) var attack_cooldown_time : float
export (float) var path_movement_speed : float
export (float) var movement_speed : float

var Player : KinematicBody2D

var following_path := true

var movement := Vector2.ZERO

func _physics_process(delta : float) -> void:
	self.movement_manager(delta)
	self.attack_manager()

func movement_manager(delta : float) -> void:
	if self.should_follow_path(): self.following_path = false
	
	if self.following_path:
		self.follow_path(delta)
	else:
		self.move(delta)

func should_follow_path() -> bool:
	var continue_following_path := true
	return self.following_path and not continue_following_path

func follow_path(delta : float) -> void:
	pass

func move(delta : float) -> void:
	pass

func attack_manager() -> void:
	pass

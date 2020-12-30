extends Control

var Game

export (bool)       var can_heal : bool
export (int, 0, 10) var health : int

onready var is_GUI_attached := false
onready var game_signals_connected := false

onready var health_indicators = [
	$Control/HealthIndicator_1,
	$Control/HealthIndicator_2,
	$Control/HealthIndicator_3,
	$Control/HealthIndicator_4,
	$Control/HealthIndicator_5,
	$Control/HealthIndicator_6,
	$Control/HealthIndicator_7,
	$Control/HealthIndicator_8,
	$Control/HealthIndicator_9,
	$Control/HealthIndicator_10
]

func _process(delta : float) -> void:
	pass

func _on_Player_can_heal(new_health_value : bool) -> void:
	self.can_heal = new_health_value
	$HealingIndicator.visible = self.can_heal

func on_Game_changed_health(new_health : int):
	self.health = new_health
	
	for i in self.health_indicators.size():
		self.health_indicators[i].visible = i <= self.health - 1

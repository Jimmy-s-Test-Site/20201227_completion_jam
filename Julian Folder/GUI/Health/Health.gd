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

func check_if_GUI_is_attached_and_set() -> void:
	if not self.is_GUI_attached and self.Game != null:
		self.is_GUI_attached = true

func connect_Game_signals_if_needed() -> void:
	if self.is_GUI_attached and not self.game_signals_connected:
		self.get_node(self.Game).connect("can_heal", self, "on_Game_can_heal")
		self.get_node(self.Game).connect("changed_health", self, "on_Game_changed_health")
		# not gonna need to change this any longer
		self.set_process(false)

func _process(delta : float) -> void:
	self.check_if_GUI_is_attached_and_set()
	self.connect_Game_signals_if_needed()

func _on_Player_can_heal(new_health_value : bool) -> void:
	self.can_heal = new_health_value
	$HealingIndicator.visible = self.can_heal

func on_Game_changed_health(new_health : int):
	self.health = new_health
	
	for i in self.health_indicators.size():
		print(health_indicators[i].name)
		self.health_indicators[i].visible = i <= self.health - 1

extends Control

var muted = false

func muteAll():
	if muted:
		print("unmuted")
		muted = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	else:
		muted = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

	

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

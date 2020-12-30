extends Control

var muted = false

func toggle_mute_all():
	if muted:
		muted = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	else:
		muted = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

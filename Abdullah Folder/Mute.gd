extends Control

var muted = false

func muteAll():
	if muted:
		muted = false
		AudioServer.set_fx_global_volume_scale(1)
	else:
		muted = true
		AudioServer.set_fx_global_volume_scale(0)
	

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

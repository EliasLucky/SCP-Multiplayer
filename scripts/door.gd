extends AnimatableBody3D

@export var open := false :
	set(v):
		if v != open:
			open = v
			update_door();
		
func update_door():
	if open:
		$AnimationPlayer.play("open");
	else:
		$AnimationPlayer.play_backwards("open");
	$AnimationPlayer.set_active(true);

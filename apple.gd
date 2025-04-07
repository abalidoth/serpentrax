extends Node2D

func _process(delta):
	%PathFollow2D.progress_ratio = 1 - %Timer.time_left/%Timer.wait_time

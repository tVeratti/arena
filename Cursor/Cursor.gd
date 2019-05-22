extends Area2D

func _input(event):
    if event is InputEventMouseMotion:
        var mouse_position = get_global_mouse_position()
        position = mouse_position
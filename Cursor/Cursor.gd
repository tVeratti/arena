extends Area2D

func _input(event):
    if event is InputEventMouseMotion:
        var x = int(event.position.x)
        var y = int(event.position.y)
        position = Vector2(x, y)
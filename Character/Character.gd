extends Node2D

var speed:float = 200.0
var path = PoolVector2Array() setget set_path

func _ready():
    set_process(false)


func _process(delta):
    var move_distance = speed * delta
    move_along_path(move_distance)


func move_along_path(distance):
    var start = position
    
    for i in range(path.size()):
        var current = path[0]
        var distance_to_next = start.distance_to(current)
        
        if distance <= distance_to_next and distance >= 0.0:
            position = start.linear_interpolate(current, distance / distance_to_next)
            break
        elif distance < 0.0:
            position = current
            set_process(false)
            break
        
        distance -= distance_to_next
        start = current
        path.remove(0)


func set_path(value:PoolVector2Array) -> void:
    path = value
    if value.size() == 0:
        return
    set_process(true)
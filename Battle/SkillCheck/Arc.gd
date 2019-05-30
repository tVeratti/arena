extends Node2D

var _max_angle:float = 30.0
var _radius:float = 100.0
var _points:PoolVector2Array


func _init(max_angle:float, radius:float):
    _max_angle = max_angle
    _radius = radius


func _draw():
    draw_polygon(_points, PoolColorArray([Color.red]))


func _get_points(factor):
    var angle_half = (_max_angle - (factor * _max_angle)) / 2
    
    var center = Vector2(100, 100)
    var b = angle_half
    var c = angle_half * -1
    
    _points = _get_arc(center, b, c)
    update()


#func _set_collision_polygon():
    #for collision in $Area2D.get_children():
        #collision.free()
    
    #var new_collision = CollisionPolygon2D.new()
   # new_collision.polygon = _points
    #$Area2D.add_child(new_collision)
    
   # update()
    
    
func _get_cone_point(angle, distance) -> Vector2 :
    return Vector2(cos(angle), sin(angle)) * distance


func _get_arc(center, angle_from, angle_to) -> PoolVector2Array:
    var num_points = 8
    var points_arc = PoolVector2Array([center])
    
    for i in range(num_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / num_points - 90)
        var angle_vector = _get_rad_vector(angle_point)       
        points_arc.push_back(center + angle_vector * _radius)
        
    return points_arc


func _get_deg_vector(angle) -> Vector2:
    var rad = deg2rad(angle)
    return Vector2(cos(rad), sin(rad))   


func _get_rad_vector(rad) -> Vector2:
    return Vector2(cos(rad), sin(rad))  
extends Node2D

class_name Telegraph

const LINE = "LINE"
const CONE = "CONE"
const COLOR:Color = Color(1,0,0,0.2)

var _mouse:Vector2
var _points:PoolVector2Array
var _bodies:Array
var _max_range:float = 75


onready var area = $Area2D
onready var parent = get_parent()


func set_range(max_range):
    _max_range = max_range * 70


func _input(event):
    if event is InputEventMouseMotion:
        _mouse = get_local_mouse_position()
        _get_points()
        _set_collision_polygon()
        
    elif event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT:
            commit_telegraph()
        elif event.button_index == BUTTON_RIGHT:
            cancel_telegraph()
            
    elif Input.is_action_pressed("actions_accept"):
        commit_telegraph()


func commit_telegraph():
    SignalManager.emit_signal("telegraph_executed", _bodies)
    queue_free()
    
func cancel_telegraph():
    SignalManager.emit_signal("telegraph_executed", [])
    queue_free()


func _process(delta):
    var new_bodies = area.get_overlapping_bodies()
    if new_bodies.size() > 0 and _bodies != new_bodies:
        _bodies = new_bodies

        var units = get_tree().get_nodes_in_group("units")
        for unit in units:
            var is_active = _bodies.has(unit) or unit == parent
            unit.set_outline(is_active)


func _draw():
    draw_polygon(_points, PoolColorArray([COLOR]))


func _get_points():
    var angle_to_mouse = rad2deg(position.angle_to_point(_mouse)) - 90
    var distance_to_mouse = clamp(position.distance_to(_mouse), 30, _max_range)
    var angle = clamp(_max_range - distance_to_mouse, 2, 90)
    
    var mouse_offset = _mouse.normalized() * 5
    var center = position + mouse_offset
    var b = angle_to_mouse - angle
    var c = angle_to_mouse + angle
    
    _points = _get_arc(center, b, c, distance_to_mouse, angle_to_mouse)


func _set_collision_polygon():
    for collision in $Area2D.get_children():
        collision.free()
    
    var new_collision = CollisionPolygon2D.new()
    new_collision.polygon = _points
    $Area2D.add_child(new_collision)
    
    update()
    
    
func _get_cone_point(angle, distance) -> Vector2 :
    return Vector2(cos(angle), sin(angle)) * distance


func _get_arc(center, angle_from, angle_to, radius, angle_to_mouse) -> PoolVector2Array:
    var num_points = 8
    var points_arc = PoolVector2Array([center])
    
    #var mouse_vector = _get_deg_vector(angle_to_mouse)
    #var radius_offset = (abs(mouse_vector.y) - abs(mouse_vector.x)) * 20
    #var total_radius = radius + radius_offset
    
    #var vector_from = _get_deg_vector(angle_from)
    #var vector_to = _get_deg_vector(angle_to)
    
    #var angle_from_offset = (abs(vector_from.y) - abs(vector_to.y)) * 10
    #var angle_to_offset = angle_from_offset * -1
    
    for i in range(num_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / num_points - 90)
        var angle_vector = _get_rad_vector(angle_point)       
        points_arc.push_back(center + angle_vector * radius)
        
    return points_arc


func _get_deg_vector(angle) -> Vector2:
    var rad = deg2rad(angle)
    return Vector2(cos(rad), sin(rad))   


func _get_rad_vector(rad) -> Vector2:
    return Vector2(cos(rad), sin(rad))   
      
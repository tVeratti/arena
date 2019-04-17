extends Node2D

class_name Telegraph

const LINE = "LINE"
const CONE = "CONE"

var _mouse:Vector2
var _points:PoolVector2Array
var _bodies:Array
var _max_range:float = 75

onready var area = $Area2D
onready var parent = get_parent()


func _ready():
    # Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    pass


func set_range(max_range):
    _max_range = max_range * 60


func _input(event):
    if event is InputEventMouseMotion:
        _mouse = get_local_mouse_position()
        _get_points()
        _set_collision_polygon()
        
    elif event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT:
            SignalManager.emit_signal("telegraph_executed", _bodies)
            # Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            queue_free()
        elif event.button_index == BUTTON_RIGHT:
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
    draw_polygon(_points, PoolColorArray([Color(1,0,0,0.3)]))


func _get_points():
    var angle_to_mouse = position.angle_to_point(_mouse) + deg2rad(180)
    var distance_to_mouse = clamp(position.distance_to(_mouse), 10, _max_range)
    var angle_offset = distance_to_mouse
    var angle = deg2rad(clamp(_max_range - angle_offset, 2, 50))
    
    var a = position
    var b = _get_cone_point(angle_to_mouse - angle, distance_to_mouse)
    var c = _get_cone_point(angle_to_mouse + angle, distance_to_mouse)
        
    _points = [a, b, c]


func _set_collision_polygon():
    for collision in $Area2D.get_children():
        collision.free()
    
    var new_collision = CollisionPolygon2D.new()
    new_collision.polygon = _points
    $Area2D.add_child(new_collision)
    
    update()
    
    
func _get_cone_point(angle, distance) -> Vector2 :
    return Vector2(cos(angle), sin(angle)) * distance
  
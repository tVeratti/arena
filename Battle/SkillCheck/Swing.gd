extends "res://Battle/SkillCheck/SkillCheck.gd"

const METER_PADDING = 15
const HIT_BASE_SIZE = 50
const CRIT_BASE_SIZE = 10

var _size:int = 200
var _speed:int = 3

var _hit_range:Array
var _crit_range:Array

const MAX_ANGLE = 60.0
const RADIUS = 100.0

const POWER_STEP = 0.03
const POWER_MAX = 1
const POWER_MIN = 0
var _power:float = 0.0
var _power_points:Array = []
var _power_angle:float = 0.0
var _power_deg:float = 0.0
var _angle_diff:float = 0.0

const VELOCITY_MIN = 0.1
const VELOCITY_MAX = 0.2
var _average_velocity:float = 0.0

const ROTATION_BASE = 5.0
const ROTATION_SPEED = 200
const ROTATION_SPREAD = 100
var _rotation_start = 0
var _rotation_end = 10
var _rotate_clockwise:bool = true

const SCORE_STEP = 3.0
var _score:float = 0.0

var _has_entered_once:bool = false
var _missed:bool = false

var _color:Color = Color.white

var _is_mouse_down:bool = false
var _is_swinging:bool = false

var _points:PoolVector2Array = []

const MOUSE_MAX_WIDTH:float = 20.0
var _prev_mouse_position:Vector2
var _mouse_points:Array

onready var _power_polygon:Polygon2D = $Power
onready var _target:Area2D = $MouseTargetArea
onready var _negative = $NegativeTargetArea
onready var _arc:Polygon2D = $Arc
onready var _swoosh:Polygon2D = $Swoosh
onready var _swoosh_timer:Timer = $SwooshTimer

func _ready():
    
    # Initialize rotation data for target and arc.
    _angle_diff = (ROTATION_SPREAD / _relative_size_ratio)
    _rotation_start = randi() % (360 - int(_angle_diff))
    _rotation_end = _rotation_start + _angle_diff
    
    _arc.rotation_degrees = _rotation_start
    _target.rotation_degrees = _arc.rotation_degrees
    update()

    _score = 0.0
    _mouse_points = []
    
    _get_points()
    _set_collision_polygon()
    _set_negative_collision_shape()


func start():
    .start()
    _arc.show()
    _power_polygon.show()


func setup(battle, unit:Unit, target_speed:float):
    .setup(battle, unit, target_speed)
    
    _get_points()


func _process(delta):
    if _is_running:
        var prev_power = _power
        var prev_swinging = _is_swinging
        var current_velocity = _get_velocity(delta)
        
        # The mouse needs to be moving a minimum speed
        # to count as a swing to prevent the player from
        # holding it still within the area.
        _is_mouse_down = Input.is_mouse_button_pressed(1)
        _is_swinging = current_velocity > VELOCITY_MIN and _is_mouse_down

        # Collisions being removed and added need a frame to init.
        yield(get_tree(), "physics_frame")
        var is_within_target = _get_is_within_area(_target)
        
        if !is_within_target:
            _rotate(delta)
        
        if !prev_swinging and _is_swinging:
            _score = 0.0

        # End the skillcheck if the player stopped swinging, or if they've exited the target.
        if (prev_swinging and !_is_swinging and _has_entered_once) or \
            (_has_entered_once and !is_within_target):
            ._resolve()
        
        if _is_swinging:
            _average_velocity = (_average_velocity + current_velocity) / 2
            
            if !is_within_target and _get_is_within_area(_negative):
                _missed = true
                ._resolve()
        
        if _is_swinging and is_within_target:
            # Update the score and track that the target has
            # been entered at least once (to prevent tiny misclicks).
            _has_entered_once = true
            _score += SCORE_STEP * delta
        else:
            # Adjust the current power based on if the mouse
            # is being held down (charged) or not.
            if _is_mouse_down:
                _power += POWER_STEP
            else:
                _power -= POWER_STEP
            
            # Clamp the power and update the progress texture.
            _power = clamp(_power, POWER_MIN, POWER_MAX)
        
        _arc.color = _color
        
        if _is_mouse_down:
            # Add a point to draw the mouse's trail while down.
            var mouse_position = get_local_mouse_position()
            _add_mouse_points(mouse_position)

        if prev_power != _power:
            # Recalculate the target's area and recreate all collision boxes.
            _get_points()
            _set_collision_polygon()


func _draw():
    draw_circle(Vector2.ZERO, RADIUS, Color(1, 1 , 1, 0.5))
    
    var angle_half = _angle_diff / 4
    var start_point = _get_cone_point(_rotation_start - 90 - angle_half)
    var end_point = _get_cone_point(_rotation_end - 90 + angle_half)
    
    draw_line(Vector2.ZERO, start_point, Color.white)
    draw_line(Vector2.ZERO, end_point, Color.white)


func _rotate(delta):
    var direction = 1 if _rotate_clockwise else -1
    var relative_rotation_speed = clamp(ROTATION_SPEED / _relative_size_ratio, 50, 100)
    var current_rotation = _arc.rotation_degrees + (relative_rotation_speed * delta * direction)
    if current_rotation > 360 or current_rotation < -360:
        current_rotation /= 360
    
    _arc.rotation_degrees = current_rotation
    _power_polygon.rotation_degrees = current_rotation
    _target.rotation_degrees = current_rotation
    
    # Flip the direction of the arc if it is close enough to one end of the spread.
    var angle_offset = (_angle_diff / 4) - _power_deg
    if (_rotate_clockwise and current_rotation >= _rotation_end + angle_offset) or \
        (!_rotate_clockwise and current_rotation <= _rotation_start - angle_offset):
            _rotate_clockwise = !_rotate_clockwise
        

func _get_is_within_area(area:Area2D) -> bool:
    if _is_mouse_down:
        # Get all overlapping areas but only register the cursor.
        var overlapping_areas = area.get_overlapping_areas()
        for area in overlapping_areas:
            if area.name == "Cursor":
                return true
    
    return false


func _get_points():
    var power_angle = (_power / 1.5) * (MAX_ANGLE)
    _power_angle = (MAX_ANGLE - power_angle) / 2
    _power_deg = _power_angle if _power_angle < 360 else _power_angle / 360
    
    var center = _arc.position
    var b = _power_angle
    var c = _power_angle * -1
    
    _get_arc(center, b, c)
    _arc.polygon = _points
    _power_polygon.polygon = _power_points


func _add_mouse_points(mouse_position:Vector2):
    var angle:float
    var prev_point
    
    var num_points = _mouse_points.size()
    if num_points > 0:
        prev_point = _mouse_points[num_points - 1];
        var diff = mouse_position - prev_point.origin
        angle = diff.x
    else:
        angle = 0.0
        prev_point = {
            "origin": Vector2.ZERO,
            "offset": Vector2.ZERO,
            "size": 0
        }
        
        
    var size = pow(_get_velocity_score(_average_velocity) * 3, 2)
    var new_point = {
        "origin": mouse_position,
        "offset": Vector2(size, size),
        "angle": angle,
        "previous": prev_point
    }
    
    _mouse_points.append(new_point)
    _swoosh.add_child(get_mouse_point_shape(new_point))

    
func get_mouse_point_shape(point):
    var prev = point.previous
    var previous_top =  prev.origin + prev.offset
    var previous_bottom = prev.origin - prev.offset
    print(point.offset)
    
    var point_shape:Polygon2D = Polygon2D.new()
    point_shape.polygon = [
        point.origin + point.offset,
        point.origin + Vector2(point.offset.x, 0), #previous_top,
        point.origin - Vector2(0, point.offset.y),#previous_bottom,
        point.origin - point.offset
    ]
    
    return point_shape


func _set_negative_collision_shape():
    var negative_shape:CollisionShape2D = CollisionShape2D.new()
    negative_shape.shape = CircleShape2D.new()
    negative_shape.shape.radius = RADIUS
    
    _negative.add_child(negative_shape)


func _set_collision_polygon():
    for collision in _target.get_children():
        collision.free()
    
    var new_collision = CollisionPolygon2D.new()
    new_collision.polygon = _points
    _target.add_child(new_collision)
    
    
func _get_cone_point(angle) -> Vector2 :
    var rad = deg2rad(angle)
    return Vector2(cos(rad), sin(rad)) * RADIUS


func _get_arc(center, angle_from, angle_to):
    var num_points = 8
    _points = PoolVector2Array([center])
    _power_points = PoolVector2Array([center])
    
    for i in range(num_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / num_points - 90)
        var angle_vector = _get_rad_vector(angle_point)       
        _points.push_back(center + angle_vector * RADIUS)
        _power_points.push_back(center + angle_vector * (RADIUS * _power))


func _get_deg_vector(angle) -> Vector2:
    var rad = deg2rad(angle)
    return Vector2(cos(rad), sin(rad))   


func _get_rad_vector(rad) -> Vector2:
    return Vector2(cos(rad), sin(rad))  


func _prepare_textures():
    ._prepare_textures()


func _get_multiplier():
    if _missed: return MISS_MULTIPLIER
    
    var velocity_score = _get_velocity_score(_average_velocity)
    var rating = (_power / 2) + (_score * velocity_score)
    
    # print("%s + (%s * %s) = %s" % [_power, _score, velocity_score, rating])
    
    if rating > 0.6: return CRIT_MULTIPLIER
    elif rating > 0.3: return HIT_MULTIPLIER
    else: return rating


func _get_velocity_score(velocity) -> float:
    return clamp(velocity, VELOCITY_MIN, VELOCITY_MAX) / VELOCITY_MAX


func _get_velocity(delta):
    var mouse_position = get_local_mouse_position()
    var velocity = mouse_position - _prev_mouse_position
    _prev_mouse_position = mouse_position
    return (abs(velocity.x) + abs(velocity.y)) * delta


func _on_SwooshTimer_timeout():
    if _mouse_points.size() > 0:
        _mouse_points.pop_front()
        _swoosh.get_child(0).queue_free()

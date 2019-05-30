extends "res://Battle/SkillCheck/SkillCheck.gd"

const METER_PADDING = 15
const HIT_BASE_SIZE = 50
const CRIT_BASE_SIZE = 10

var _size:int = 200
var _speed:int = 3

var _hit_range:Array
var _crit_range:Array

const MAX_ANGLE = 60
const RADIUS = 100

const POWER_STEP = 0.01
const POWER_MAX = 1
const POWER_MIN = 0
var _power:float = 0.0

const VELOCITY_MIN = 50.0
const VELOCITY_MAX = 1000.0
var _velocity:Vector2 = Vector2.ZERO
var _abs_velocity:float setget , _get_velocity
var _average_velocity:float = 0.0

const SCORE_STEP = 2.0
var _score:float = 0.0

var _has_entered_once:bool = false

var _color:Color = Color.white

var _is_mouse_down:bool = false
var _is_swinging:bool = false

var _points:PoolVector2Array = []
var _mouse_points:PoolVector2Array = []

onready var _power_progress = $Power
onready var _arc = $Arc
onready var _target = $MouseTargetArea


func start():
    .start()
    _get_points()
    _set_collision_polygon()
    update()
    

func _process(delta):
    if _is_running:
        var prev_power = _power
        var prev_swinging = _is_swinging
        
        # The mouse needs to be moving a minimum speed
        # to count as a swing to prevent the player from
        # holding it still within the area.
        _is_swinging = self._abs_velocity > VELOCITY_MIN and _is_mouse_down
        
        yield(get_tree(), "physics_frame")
        var is_within_target = false
        if _is_mouse_down:
            var overlapping_areas = _target.get_overlapping_areas()
            for area in overlapping_areas:
                if area.name == "Cursor":
                    is_within_target = true
                    break

        if (prev_swinging and !_is_swinging and _has_entered_once) or \
            (_has_entered_once and !is_within_target):
            ._resolve()
        
        if _is_swinging and is_within_target:
            _has_entered_once = true
            _score += SCORE_STEP * delta
            _color = Color.yellow
        else:
            # Adjust the current power based on if the mouse
            # is being held down (charged) or not.
            if _is_mouse_down:
                _power += POWER_STEP
                _color = Color.green
            else:
                _power -= POWER_STEP
                _color = Color.gray
            
            _power = clamp(_power, POWER_MIN, POWER_MAX)
            _power_progress.value = _power
        
        if _is_mouse_down:
            var mouse_position = get_local_mouse_position()
            _mouse_points.append(mouse_position)
        
        if prev_power != _power:
            _get_points()
            _set_collision_polygon()
            update()
        elif _is_swinging:
            update()
            

func _input(event):
    _is_mouse_down = Input.is_mouse_button_pressed(1)
    
    if event is InputEventMouseMotion and _is_mouse_down:
        _velocity = event.get_speed()


func _draw():
    if _points.size() > 2:
        draw_polygon(_points, PoolColorArray([_color]))
    
    if _mouse_points.size() > 2:
        draw_polyline(_mouse_points, Color.blue, 5.0)


func _get_points():
    var angle_half = (MAX_ANGLE - ((_power / 1.5) * MAX_ANGLE)) / 2
    
    var center = _arc.rect_position
    var b = angle_half
    var c = angle_half * -1
    
    _points = _get_arc(center, b, c)


func _set_collision_polygon():
    for collision in _target.get_children():
        collision.free()
    
    var new_collision = CollisionPolygon2D.new()
    new_collision.polygon = _points
    _target.add_child(new_collision)
    
    
func _get_cone_point(angle, distance) -> Vector2 :
    return Vector2(cos(angle), sin(angle)) * distance


func _get_arc(center, angle_from, angle_to) -> PoolVector2Array:
    var num_points = 8
    var points_arc = PoolVector2Array([center])
    
    for i in range(num_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / num_points - 90)
        var angle_vector = _get_rad_vector(angle_point)       
        points_arc.push_back(center + angle_vector * RADIUS)
        
    return points_arc


func _get_deg_vector(angle) -> Vector2:
    var rad = deg2rad(angle)
    return Vector2(cos(rad), sin(rad))   


func _get_rad_vector(rad) -> Vector2:
    return Vector2(cos(rad), sin(rad))  


func _prepare_textures():
    ._prepare_textures()


func _get_multiplier():
    var velocity_score = clamp(_average_velocity, VELOCITY_MIN, VELOCITY_MAX) / VELOCITY_MAX
    var rating = _power + (_score * velocity_score)
    
    print("%s + (%s * %s) = %s" % [_power, _score, velocity_score, rating])
    
    if rating > 2: return CRIT_MULTIPLIER
    elif rating > 1: return HIT_MULTIPLIER
    elif rating > 0.1: return rating
    else: return 0.0


func _get_velocity():
    var velocity = abs(_velocity.x) + abs(_velocity.y)
    _average_velocity = (_average_velocity + velocity) / 2
    return velocity

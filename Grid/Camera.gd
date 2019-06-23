extends Camera2D

const MIN_ZOOM = Vector2.ZERO
const MAX_ZOOM = Vector2(10, 10)
const DEFAULT_ZOOM = Vector2(2, 2)

# Target
onready var _target:Vector2 = position
var _speed:float = 5.0
var _manual_speed:float = 15.0
var _tolerance:float = 0.1

# Zoom
onready var _zoom_target:Vector2 = zoom
var _zoom_speed:float = 8.0
var _zoom_step:Vector2 = Vector2(0.3, 0.3)
var _zoom_tolerance:float = 0.1

# Cinematic
var _playing_cinematic:bool = false
var _prev_target:Vector2 = _target
var _prev_zoom_target:Vector2 = _zoom_target
var _input_target_active:bool = false
var _input_zoom_active:bool = false
var _canceled_by_target:bool = false
var _canceled_by_zoom:bool = false

var _camera_locked:bool = false


func _ready():
    _zoom_target = DEFAULT_ZOOM
    zoom = DEFAULT_ZOOM - _zoom_step


func _process(delta):
    _manual_camera_input()
    
    # Move the camera to the target tile (x, y)
    var distance = position.distance_to(_target)
    if distance >= _tolerance:
        position = Vector2(\
        lerp(position.x, _target.x, _speed * delta),\
        lerp(position.y, _target.y, _speed * delta))
    
    # Zoom the camera in/out (z)
    var zoom_distance = zoom.distance_to(_zoom_target)
    if zoom_distance >= _zoom_tolerance:
        zoom = Vector2(\
        clamp(lerp(zoom.x, _zoom_target.x, _zoom_speed * delta), MIN_ZOOM.x, MAX_ZOOM.x), \
        clamp(lerp(zoom.y, _zoom_target.y, _zoom_speed * delta), MIN_ZOOM.y, MAX_ZOOM.y))


func _input(event):
    if not _camera_locked:
        _input_zoom_active = false
        if event is InputEventMouse and event.is_pressed():
            if event.button_index == BUTTON_WHEEL_UP:
                adjust_zoom(-1)
                cancel_cinematic()
            elif event.button_index == BUTTON_WHEEL_DOWN:
                adjust_zoom(1)
                cancel_cinematic()

       
func _manual_camera_input():
    if not _camera_locked:
        _input_target_active = false
        
        # Manual camera _target movement
        if Input.is_action_pressed("ui_up"):
            adjust_target(Vector2.UP)
        if Input.is_action_pressed("ui_down"):
            adjust_target(Vector2.DOWN)
        if Input.is_action_pressed("ui_right"):
            adjust_target(Vector2.RIGHT)
        if Input.is_action_pressed("ui_left"):
            adjust_target(Vector2.LEFT)
            
        if _input_target_active: cancel_cinematic()

func adjust_target(direction:Vector2):
    _target += direction * _manual_speed
    _input_target_active = true
    

func set_target(target):
    if not _camera_locked:
        _target = target


func adjust_zoom(factor:float):
    _zoom_target = zoom + (_zoom_step * factor)
    _input_zoom_active = true


func set_zoom_target(target:Vector2):
    _zoom_target = target


func start_cinematic_target(target):
    _playing_cinematic = true
    _prev_target = _target
    _prev_zoom_target = _zoom_target
    set_target(target)
    set_zoom_target(Vector2(1.5, 1.5))


func end_cinematic_target():
    _playing_cinematic = false
    if !_canceled_by_target: set_target(_prev_target)
    if !_canceled_by_zoom: set_zoom_target(_prev_zoom_target)


func cancel_cinematic():
    _canceled_by_target = _input_target_active
    _canceled_by_zoom = _input_zoom_active


func lock():
    _camera_locked = true


func unlock():
    _camera_locked = false


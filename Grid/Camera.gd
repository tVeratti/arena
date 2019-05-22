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
        if event is InputEventMouse and event.is_pressed():
            if event.button_index == BUTTON_WHEEL_UP:
                _zoom_target = zoom - _zoom_step
            elif event.button_index == BUTTON_WHEEL_DOWN:
                _zoom_target = zoom + _zoom_step

       
func _manual_camera_input():
    if not _camera_locked:
        # Manual camera _target movement
        if Input.is_action_pressed("ui_up"):
            _target.y -= _manual_speed
        if Input.is_action_pressed("ui_down"):
            _target.y += _manual_speed
        if Input.is_action_pressed("ui_right"):
            _target.x += _manual_speed
        if Input.is_action_pressed("ui_left"):
            _target.x -= _manual_speed


func set_target(target):
    if not _camera_locked:
        _target = target


func lock():
    _camera_locked = true


func unlock():
    _camera_locked = false


extends "res://Battle/SkillCheck/SkillCheck.gd"

const METER_PADDING = 15
const HIT_BASE_SIZE = 50
const CRIT_BASE_SIZE = 10

var _size:int = 200
var _speed:int = 3

var _hit_range:Array
var _crit_range:Array

onready var _hit = $Textures/Hit
onready var _crit = $Textures/Critical
onready var _val = $Textures/Value

onready var _timer_texture = $Textures/Container/TimerTexture


func _process(delta):
    if _is_running:        
        # Update the texture position of the value indicator.
        _val.rect_position = Vector2(\
            lerp(self._value, _size, _speed * delta),\
            _val.rect_position.y)
        
        # Resolve immediately if the accept action is fired.
        if Input.is_action_pressed("actions_accept"):
            ._resolve()
            return

        # Resolve if the skillcheck has left its bounds.
        if self._value >= _size:
            ._resolve()
    else:
        _timer_texture.value = _prep_time_elapsed


func start():
    .start()
    _timer_texture.queue_free()


func _prepare_textures():
    ._prepare_textures()
    
    var hit_size = HIT_BASE_SIZE * _relative_size_ratio
    var crit_size = CRIT_BASE_SIZE * (_relative_size_ratio / 2)

    var hit_start = (_size - hit_size) - METER_PADDING
    var crit_start = (_size - crit_size) - METER_PADDING
    
    _hit_range = [hit_start, hit_start + hit_size]
    _crit_range = [crit_start, crit_start + crit_size]

    _hit_range = [hit_start, hit_start + hit_size]
    _crit_range = [crit_start, crit_start + crit_size]

    # Size all target areas based on speed ranges.
    $Textures/Hit.rect_size.x = hit_size
    $Textures/Hit.rect_position.x = clamp(_hit_range[0], 40, _size)
    $Textures/Critical.rect_size.x = crit_size
    $Textures/Critical.rect_position.x = clamp(_crit_range[0], 50, _size)

    $Textures/Container/TimerTexture.max_value = PREP_TIMER_LENGTH


func _get_value():
    return _val.rect_position.x


func _get_multiplier():
    # Get the multiplier value based on the current value
    # and its position relative to the hit ranges.
    var value = self._value + (_val.rect_size.x / 2)
    var multiplier = 1

    if value > _crit_range[0] and value < _crit_range[1]:
        multiplier = CRIT_MULTIPLIER
    elif value > _hit_range[0] and value < _hit_range[1]:
        multiplier = HIT_MULTIPLIER
    else:
        multiplier = 0
    
    return multiplier


func _on_Button_pressed():
    ._resolve()
extends Control

# Types
const SWORD = "SWORD"
const CLUB = "CLUB"
const DAGGER = "DAGGER"
const BOW = "BOW"

# Multipliers
const BONUS_MULTIPLIER = 1.2
const CRIT_MULTIPLIER = 1.5

var _type:String
var _speed:int = 3
var _size:int = 200

# Texture Measurements
const WINDOW_PADDING = 100
const METER_PADDING = 15
const BONUS_BASE_SIZE = 50
const CRIT_BASE_SIZE = 10
var _bonus_range:Array = []
var _crit_range:Array = []

onready var _value_indicator = $Textures/Value
var _value:int = 0 setget , _get_value

# Preparation Timer
const TIMER_LENGTH:float = 2000.0
var _start_time:float = 0.0
var _elapsed_time:float = 0.0
var running:bool = false
onready var _timer_texture = $Textures/Container/TimerTexture

# Battle reference to resolve the attack once
# the skill check has full completed its cycle.
var _battle

onready var free_timer = $FreeTimer


func _ready():
    # Don't start the skill check right away.
    _start_time = OS.get_ticks_msec()
    _timer_texture.max_value = TIMER_LENGTH
    
    #$AnimationPlayer.play("Enter")


func _process(delta):
    if running:
        # Run the skillcheck and track the value.
        _value_indicator.rect_position = Vector2(\
            lerp(self._value, _size, _speed * delta),\
            _value_indicator.rect_position.y)
        
        if Input.is_action_pressed("actions_accept"):
            calculate_multiplier()
            return

        if self._value >= _size - 5:
            calculate_multiplier()
    else:
        # Animate the prep timer...
        _timer_texture.value = TIMER_LENGTH - (OS.get_ticks_msec() - _start_time)
        if _timer_texture.value <= 0:
            start()



func setup(battle, unit:Unit, target_speed:float):
    _battle = battle

    # Calculate the size of the targets based on attacker/target speeds.
    var speed_total:float = unit.character.speed + target_speed
    var relative_size_ratio:float = unit.character.speed / speed_total
    
    var bonus_size = BONUS_BASE_SIZE * relative_size_ratio
    var crit_size = CRIT_BASE_SIZE * (relative_size_ratio / 2)
    
    var bonus_start = (_size - bonus_size) - METER_PADDING
    var crit_start = (_size - crit_size) - METER_PADDING
    
    _bonus_range = [bonus_start, bonus_start + bonus_size]
    _crit_range = [crit_start, crit_start + crit_size]
    
    # Position the skill check beside the player unit, but within the viewport.
    var target_position = unit.get_global_transform_with_canvas().get_origin() - Vector2(_size / 2, 0)
    var window_size = OS.window_size
    $Textures.rect_position = Vector2(\
        clamp(target_position.x, WINDOW_PADDING, window_size.x - (_size + WINDOW_PADDING)),\
        clamp(target_position.y, WINDOW_PADDING, window_size.y - WINDOW_PADDING))
    
    # Size all target areas based on speed ranges.
    $Textures/Target.rect_size.x = bonus_size
    $Textures/Target.rect_position.x = clamp(_bonus_range[0], 40, _size)
    $Textures/Critical.rect_size.x = crit_size
    $Textures/Critical.rect_position.x = clamp(_crit_range[0], 50, _size)
    
    
    
func calculate_multiplier():
    set_process(false)
    
    # Get the multiplier value based on the current value
    # and its position relative to the bonus ranges.
    var value = self._value + (_value_indicator.rect_size.x / 2)
    var label = ""
    var multiplier = 1
    if value > _crit_range[0] and value < _crit_range[1]:
        multiplier = CRIT_MULTIPLIER
        label = "CRITICAL!"
    elif value > _bonus_range[0] and value < _bonus_range[1]:
        multiplier = BONUS_MULTIPLIER
        label = ""
    else:
        multiplier = 0
        label = "Missed!"
    
    # Allow battle to finish resolving the attack with
    # the new multiplier from this skill check.
    _battle.resolve_attack(multiplier, label)
    
    free_timer.start(1)


func start():
    running = true
    _timer_texture.queue_free()


func _on_Button_pressed():
    calculate_multiplier()


func _get_value():
    return _value_indicator.rect_position.x


func _on_FreeTimer_timeout():
    self.queue_free()
    

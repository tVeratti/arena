extends CanvasLayer

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

# Battle reference to resolve the attack once
# the skill check has full completed its cycle.
var _battle


func _ready():
    set_process(false)
        
    # Don't start the skill check right away.
    $Timer.start(2)


func _process(delta):
    _value_indicator.rect_position = Vector2(\
        lerp(self._value, _size, _speed * delta),\
        _value_indicator.rect_position.y)

    if self._value >= _size - 5:
        calculate_multiplier()


func setup(battle, unit:Unit, target_speed:float):
    _battle = battle
    print(target_speed)
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
    var target_position = unit.get_global_transform_with_canvas().get_origin()
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
    var value = self._value
    var label = ""
    var multiplier = 1
    if value > _crit_range[0] and value < _crit_range[1]:
        multiplier = CRIT_MULTIPLIER
        label = "Great!"
    elif value > _bonus_range[0] and value < _bonus_range[1]:
        multiplier = BONUS_MULTIPLIER
        label = "Good!"
    else:
        multiplier = 0
        label = "Missed!"
    
    # Allow battle to finish resolving the attack with
    # the new multiplier from this skill check.
    _battle.resolve_attack(multiplier, label)
    
    # Delete instance entirely
    self.queue_free()


func _on_Button_pressed():
    calculate_multiplier()
   

func _on_Timer_timeout():
    set_process(true)


func _get_value():
    return _value_indicator.rect_position.x

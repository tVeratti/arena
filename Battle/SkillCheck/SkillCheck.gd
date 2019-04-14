extends Node2D

# Types
const SWORD = "SWORD"
const CLUB = "CLUB"
const DAGGER = "DAGGER"
const BOW = "BOW"

# Multipliers
const BONUS_MULTIPLIER = 1.2
const CRIT_MULTIPLIER = 1.5

var _type:String
var _speed:int = 2
var _size:int = 200

# Texture Measurements
var _bonus_start:int = 115
var _crit_start:int = 150
var _bonus_size:int = 50
var _crit_size:int = 10

var _bonus_range:Array = [_bonus_start, _bonus_start + _bonus_size]
var _crit_range:Array = [_crit_start, _crit_start + _crit_size]

onready var _value_indicator = $Value
var _value:int = 0 setget , _get_value

# Battle reference to resolve the attack once
# the skill check has full completed its cycle.
var _battle


func _ready():
    set_process(false)
    
    # Set up targets to make sure ranges line up.
    $Target.rect_position.x = _bonus_range[0]
    $Critical.rect_position.x = _crit_range[0]
    
    # Don't start the skill check right away.
    $Timer.start(2)


func _process(delta):
    _value_indicator.rect_position = Vector2(\
    lerp(self._value, _size, _speed * delta),\
    _value_indicator.rect_position.y)

        
    if self._value >= _size - 5:
        calculate_multiplier()


func setup(battle, type):
    _type = type
    _battle = battle
    
    
func calculate_multiplier():
    set_process(false)
    
    # Get the multiplier value based on the current value
    # and its position relative to the bonus ranges.
    var value = self._value
    var multiplier = 1
    if value > _crit_range[0] and value < _crit_range[1]:
        multiplier = CRIT_MULTIPLIER
    elif value > _bonus_range[0] and value < _bonus_range[1]:
        multiplier = BONUS_MULTIPLIER
    
    # Allow battle to finish resolving the attack with
    # the new multiplier from this skill check.
    _battle.resolve_attack(multiplier)
    
    # Delete instance entirely
    self.queue_free()

func _on_Button_pressed():
    calculate_multiplier()
   

func _on_Timer_timeout():
    set_process(true)

func _get_value():
    return _value_indicator.rect_position.x

extends Node

class_name Stat

var value_maximum:int = 0
var value_minimum:int = 0
var value_current:int = 0 setget _set_current, _get_current

var modifiers:Array = []


func _init(maximum, minimum = 0, current = null):
    value_minimum = minimum
    value_maximum = maximum
    self.value_current = current if current != null else maximum

func _set_current(value):
    value_current = clamp(value, value_minimum, value_maximum)
    
func _get_current():
    var initial = value_current
    
    for mod in modifiers:
        initial += mod

    return clamp(initial, value_minimum, value_maximum)
    
func set_base(value):
    value_maximum = value
    value_current = value
extends Object

var direction:Vector2
var target:Unit
var _bonus:float

func _init(target:Unit, direction:Vector2, bonus:float):
    _bonus = bonus
    self.target = target
    self.direction = direction


func check(target:Unit, direction:Vector2) -> float:
    if target == self.target and direction == self.direction:
        print("BONUS ", _bonus)
        return _bonus
    else: return 1.0
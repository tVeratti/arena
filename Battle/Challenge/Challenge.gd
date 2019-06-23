extends Object

const DIRECTIONS = [
    Vector2.UP,
    Vector2.DOWN,
    Vector2.RIGHT,
    Vector2.LEFT
]

var tile:Vector2
var target:Unit
var _relative_facing:String
var _bonus:float

func setup(target:Unit, attacker:Unit):
    
    _bonus = attacker.character.acuity
    self.target = target
    # Generate a direction
    tile = DIRECTIONS[randi() % DIRECTIONS.size()]
    _relative_facing = Facing.get_relative_facing(target, target.coord + tile)
    print("wiat...", _relative_facing)


func check(target:Unit, attacker:Unit) -> float:
    var relative_facing = Facing.get_relative_facing(target, attacker.coord)
    if target == self.target and relative_facing == _relative_facing:
        return _bonus
    else: return 1.0
    
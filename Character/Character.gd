extends Object

class_name Character

const HEALTH_MAX = 100
const EXPERIENCE_MAX = 1000
const NATURAL_MAX = 5
const TOUGH_MAX = 20
const SPEED_MAX = 10
const POWER_MAX = 30

var id:String
var name:String

var health:Stat = Stat.new(HEALTH_MAX)
var experience:Stat = Stat.new(EXPERIENCE_MAX, 0, 0)
var level:int = 1

# Natural Stats
# ------------------------------
# These change VERY SLOWLY and passively, they are
# meant to reflect the character's natural abilities.

# Acuity
# + experience gain increased
# + weaknesses exposed if greater than opponent
# * improve by observing enemies, countering weaknesses
var acuity:int

# Constitution
# + toughness
# + power
# - speed
# * improve by taking damage, dealing damage
var constitution:int

# Agility
# + speed
# + power
# - toughness
# * improve by moving, dealing damage
var agility:int

# Calculated Stats
# ------------------------------
# These are the stats used in combat. They are based
# on natural stats and can be affected by different
# statuses, gear, and buffs.

# Toughness
# + damage mitigation
# + chance to resist dying when reduced to 0
var toughness:int setget , toughness_get

# Speed
# + damage avoidance
# + move distance
var speed:int setget , speed_get

# Power
# + damage dealt
var power:int setget , power_get


func _init(name):
    self.name = name
    self.id = "%s_%s" % [name, randi()]
    
    # Load character or create new one...
    # _load_stats or
    _generate_stats()


func _load_stats():
    pass


func _generate_stats():
    randomize()
    acuity = _generate_natural()
    constitution = _generate_natural()
    agility = _generate_natural()


func _generate_natural():
    return int(rand_range(1, NATURAL_MAX))


func take_damage(value):
    var damage = value - constitution
    health.value_current -= damage


func deal_damage():
    return power + speed


func toughness_get():
    var base = constitution - int(agility / 2)
    return clamp(base, 1, TOUGH_MAX)


func speed_get():
    var base = agility - int(constitution / 2)
    return clamp(base, 2, SPEED_MAX)


func power_get():
    return clamp(agility + constitution, 1, POWER_MAX)
    

extends Object

class_name Character

const HEALTH_MAX = 100
const EXPERIENCE_MAX = 1000

const NATURAL_BASE = 2
const NATURAL_POOL = 10

const DAMAGE_MULTIPLIER = 2

var id:String
var name:String
var gender:String
var is_enemy:bool
var is_alive:bool setget , _alive_get

# Unit & Portrait Textures
var PARTS = preload("res://Generator/Part.gd").PARTS
var textures:Dictionary

# General Info
var health:Stat = Stat.new(HEALTH_MAX)
var experience:Stat = Stat.new(EXPERIENCE_MAX, 0, 0)
var level:int = 1
var rating:int = 1

var attack_range:int = 1


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
# + accuracy
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
var toughness:int setget , _toughness_get

# Speed
# + damage avoidance
# + move distance
var speed:int setget , _speed_get

# Power
# + damage dealt
var power:int setget , _power_get


func _init(name, is_enemy = false):
    self.name = name
    self.id = "%s_%s" % [name, randi()]
    self.is_enemy = is_enemy
    
    # Load character or create new one...
    # _load_stats or
    _generate()


func _load_stats():
    pass


func _generate():
    randomize()
    
    # Character stats
    var pool_points = _generate_natural_pool()
    acuity = pool_points[0]
    constitution = pool_points[1]
    agility = pool_points[2]
        
    textures = {}
    for part in PARTS:
        textures[part] = random_texture()


func random_texture():
    var index = int(rand_range(0.0, 3.0))
    return Resources.spritesheets[index]


func _generate_natural_pool() -> Array:
    var pool = int(rand_range(NATURAL_POOL - 2, NATURAL_POOL + 2))
    rating = pool

    var points = [NATURAL_BASE, NATURAL_BASE, NATURAL_BASE]
    for i in range(pool):
        var rand = rand_range(0, 3)
        if rand > 2:
            points[0] += 1
        elif rand > 1:
            points[1] += 1
        else:
            points[2] += 1
        
    return points


func take_damage(value) -> int:
    var damage = clamp(int(value - constitution), 0, health.value_current)
    health.value_current -= damage
    return damage


func deal_damage():
    var power_bonus = rand_range(self.power, self.power * DAMAGE_MULTIPLIER)
    var acuity_bonus = rand_range(self.acuity, self.acuity * DAMAGE_MULTIPLIER)
    return self.power + power_bonus + acuity_bonus


func _toughness_get() -> int:
    return int(constitution - int(agility / 3))


func _speed_get() -> int:
    var base = agility - int(constitution / 2)
    if base <= 0:
        base = 1
    return base


func _power_get() -> int:
    return int(constitution * 1.2)
    

func _alive_get() -> bool:
    return health.value_current > 0

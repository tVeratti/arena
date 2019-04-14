extends Object

class_name Character

const HEALTH_MAX = 100
const EXPERIENCE_MAX = 1000

const NATURAL_BASE = 2
const NATURAL_POOL = 10

const DAMAGE_MULTIPLIER = 2

var id:String
var name:String

# Unit & Portrait Textures
var TEXTURES = preload("res://Character/TEXTURES.gd")
var unit_texture:Texture
var portrait_texture:Texture

# General Info
var health:Stat = Stat.new(HEALTH_MAX)
var experience:Stat = Stat.new(EXPERIENCE_MAX, 0, 0)
var level:int = 1

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
var toughness:float setget , toughness_get

# Speed
# + damage avoidance
# + move distance
var speed:float setget , speed_get

# Power
# + damage dealt
var power:float setget , power_get


func _init(name):
    self.name = name
    self.id = "%s_%s" % [name, randi()]
    
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
    
    # Set portrait & unit textures
    # TODO: Use some algorithm to create
    # new asset combinations and unique textures.
    var texture = TEXTURES.CIRCLE if randi() % 2 == 0 else TEXTURES.CIRCLE_YELLOW
    unit_texture = texture
    portrait_texture = texture


func _generate_natural_pool() -> Array:
    var points = [NATURAL_BASE, NATURAL_BASE, NATURAL_BASE]
    for i in range(NATURAL_POOL):
        var rand = rand_range(0, 3)
        if rand > 2:
            points[0] += 1
        elif rand > 1:
            points[1] += 1
        else:
            points[2] += 1
        
    return points


func take_damage(value) -> int:
    var damage = int(value - constitution)
    health.value_current -= damage
    return damage


func deal_damage():
    var power_bonus = rand_range(self.power, self.power * DAMAGE_MULTIPLIER)
    var acuity_bonus = rand_range(self.acuity, self.acuity * DAMAGE_MULTIPLIER)
    return self.power + power_bonus + acuity_bonus


func toughness_get():
    return constitution - int(agility / 3)


func speed_get():
    return agility - int(constitution / 2)


func power_get():
    return constitution * 1.5
    

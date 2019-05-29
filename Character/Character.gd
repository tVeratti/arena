extends Object

class_name Character

const HEALTH_MAX = 100
const EXPERIENCE_MAX = 1000

# Stat generation (pool range).
const NATURAL_BASE = 2
const NATURAL_POOL = 10
const NATURAL_POOL_VARIANCE = 3
const NATURAL_POOL_AVERAGE = NATURAL_POOL + (NATURAL_POOL_VARIANCE / 2)

const DAMAGE_MULTIPLIER = 2
const ACUITY_MULTIPLIER = 0.25

# Stat constants for outside reference.
const ACUITY = "Acuity"
const CONSTITUTION = "Constitution"
const AGILITY = "Agility"


# General Info
# ------------------------------
var id:String
var name:String
var gender:String
var is_enemy:bool
var is_alive:bool setget , _alive_get
var attack_range:int = 1

var health:MinMax = MinMax.new(HEALTH_MAX)

# Rating is a rough estimate of the character's overal combat strength.
var rating:int = 1 setget , _rating_get
var talent:int = 1 setget , _talent_get

# Unit & Portrait Textures
# ------------------------------
# These properties are use to generate unqiue character textures and colors.
var PARTS = preload("res://Generator/Part.gd").PARTS
var Colors = preload("res://Character/Colors.gd");
var textures:Dictionary
var colors:Dictionary = {
    'hair': [],
    'skin': [],
    'clothes': [],
    'eyes': []
}


# Natural Stats
# ------------------------------
# These change VERY SLOWLY and passively, they are
# meant to reflect the character's natural abilities.

# Acuity
# + experience gain increased
# + weaknesses exposed if greater than opponent
# * improve by observing enemies, countering weaknesses
var acuity:int setget , _acuity_get
var acuity_stat:Stat
const ACUITY_PROGRESS_FACTOR = 5

# Constitution
# + toughness
# + power
# - speed
# * improve by taking damage, dealing damage
var constitution:int setget , _constitution_get
var constitution_stat:Stat
const CONSTITUTION_PROGRESS_FACTOR = 5

# Agility
# + speed
# + accuracy
# - toughness
# * improve by moving, dealing damage
var agility:int setget , _agility_get
var agility_stat:Stat
const AGILITY_PROGRESS_FACTOR = 10

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
    
    acuity_stat = Stat.new(ACUITY, ACUITY_PROGRESS_FACTOR)
    constitution_stat = Stat.new(CONSTITUTION, CONSTITUTION_PROGRESS_FACTOR)
    agility_stat = Stat.new(AGILITY, AGILITY_PROGRESS_FACTOR)
    
    # Load character or create new one...
    # _load_stats or
    generate()


func _load_stats():
    pass


func generate():
    randomize()
    
    # Character stats
    var pool_points = _generate_natural_pool()
    acuity_stat.base = pool_points[0]
    constitution_stat.base = pool_points[1]
    agility_stat.base = pool_points[2]
        
    textures = {}
    for part in PARTS:
        textures[part] = random_texture(part)
    
    # Colors
    colors.hair = Colors.random_hair()
    colors.skin = Colors.random_skin()
    colors.clothes = Colors.random_clothes()
    colors.eyes = Colors.random_eyes()


func random_texture(part):
    var textures = Resources.spritesheets[part]
    var index = int(rand_range(0.0, textures.size()))
    return textures[index]


func _generate_natural_pool() -> Array:
    var pool = int(rand_range(\
        NATURAL_POOL - NATURAL_POOL_VARIANCE,\
        NATURAL_POOL + NATURAL_POOL_VARIANCE))
    

    var points = [NATURAL_BASE, NATURAL_BASE, NATURAL_BASE]
    for i in range(pool):
        var rand = rand_range(0, 3)
        if rand > 2: points[0] += 1
        elif rand > 1: points[1] += 1
        else: points[2] += 1
        
    return points


func take_damage(value) -> int:
    var damage = clamp(int(value - constitution), 0, health.value_current)
    health.value_current -= damage
    return damage


func deal_damage():
    var power_bonus = rand_range(self.power, self.power * DAMAGE_MULTIPLIER)
    var acuity_bonus = rand_range(self.acuity, self.acuity * DAMAGE_MULTIPLIER)
    return self.power + power_bonus + acuity_bonus


func progress_stat(stat:String, amount:int):
    match(stat):
        ACUITY: acuity_stat.add_progress(amount)
        CONSTITUTION: constitution_stat.add_progress(amount)
        AGILITY: agility_stat.add_progress(amount)
    
    SignalManager.emit_signal("stat_changed", self)
        

# Base Stat Getters
# ------------------------------

func _acuity_get() -> int:
    return acuity_stat.value


func _constitution_get() -> int:
    return constitution_stat.value


func _agility_get() -> int:
    return agility_stat.value



# Derived Stat Getters
# ------------------------------

func _toughness_get() -> int:
    return int(self.constitution - int(self.agility / 3))


func _speed_get() -> int:
    var base = self.agility - int(self.constitution / 2)
    if base <= 0: base = 1
    return base


func _power_get() -> int:
    return int(self.constitution * 1.2)


# Getters
# ------------------------------

func _alive_get() -> bool:
    return health.value_current > 0


func _talent_get() -> int:
    var base_sum = acuity_stat.base + constitution_stat.base + agility_stat.base
    return base_sum - NATURAL_POOL_AVERAGE


func _rating_get() -> int:
    var value_sum = self.power + self.speed + self.constitution + self.acuity
    return value_sum / NATURAL_POOL_AVERAGE

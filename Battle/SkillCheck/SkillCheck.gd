extends Control

# Types
const SWORD = "SWORD"
const CLUB = "CLUB"
const DAGGER = "DAGGER"
const BOW = "BOW"

# Multipliers
const HIT_MULTIPLIER = 1
const CRIT_MULTIPLIER = 1.5

var _relative_size_ratio:float

var _value:int = 0 setget , _get_value
var _multiplier:int = 1 setget , _get_multiplier

# Preparation Timer
const PREP_TIMER_LENGTH:float = 2000.0
var _start_time:float = 0.0
var _prep_time_elapsed:float = 0.0
var _is_running:bool = false

# Battle reference to resolve the attack once
# the skill check has full completed its cycle.
var _battle
var _unit


func _ready():
    # Don't start the skill check right away.
    _start_time = OS.get_ticks_msec()

    _prepare_textures()


func _process(delta):
    if !_is_running:
        _prep_time_elapsed = PREP_TIMER_LENGTH - (OS.get_ticks_msec() - _start_time)
        if _prep_time_elapsed <= 0:
            start()



func setup(battle, unit:Unit, target_speed:float):
    _battle = battle
    _unit = unit

    # Calculate the size of the targets based on attacker/target speeds.
    var speed_total:float = unit.character.speed + target_speed
    _relative_size_ratio = unit.character.speed / speed_total


# Each type overrides this to determine how to set up the textures
# based on the crit and hit ranges calculated on setup.
func _prepare_textures():
    pass


func _resolve():
    set_process(false)
    
    # Allow battle to finish resolving the attack with
    # the new multiplier from this skill check.
    _battle.resolve_attack(self._multiplier)
    
    # Delay removing from UI so the player can see the result.
    $FreeTimer.start(1)


func start():
    _is_running = true


func _on_FreeTimer_timeout():
    self.queue_free()


func _get_value():
    pass


func _get_multiplier():
    pass
    

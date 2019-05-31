extends Control

# Types
const SWORD = "SWORD"
const CLUB = "CLUB"
const DAGGER = "DAGGER"
const BOW = "BOW"

# Multipliers
const MISS_MULTIPLIER:float = 0.0
const HIT_MULTIPLIER:float = 1.0
const CRIT_MULTIPLIER:float = 1.5
const HIT_LABEL = ""
const CRIT_LABEL = "CRIT!"
const MISSED_LABEL = "Missed"

var _relative_size_ratio:float = 1.0

var _value:int = 0 setget , _get_value
var _multiplier:float = 1 setget , _get_multiplier

# Preparation Timer
const PREP_TIMER_LENGTH:float = 2000.0
var _start_time:float = 0.0
var _prep_time_elapsed:float = 0.0
var _is_running:bool = false

# Battle reference to resolve the attack once
# the skill check has full completed its cycle.
var _battle
var _unit

var _free_timer:Timer


func _ready():
    _free_timer = Timer.new()
    _free_timer.one_shot = true
    _free_timer.connect("timeout", self, "_on_FreeTimer_timeout")
    add_child(_free_timer)
    
    
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
    var speed_total:float = float(unit.character.speed) + target_speed
    _relative_size_ratio = float(unit.character.speed) / speed_total


# Each type overrides this to determine how to set up the textures
# based on the crit and hit ranges calculated on setup.
func _prepare_textures():
    # Position the skill check beside the player unit, but within the viewport.
    var window_size = OS.window_size
    rect_position = Vector2(\
        (window_size.x / 2), \
        (window_size.y / 2))


func _resolve():
    set_process(false)
    
    # Allow battle to finish resolving the attack with
    # the new multiplier from this skill check.
    var multiplier:float = self._multiplier
    print("multiplier: ", multiplier)
    
    var label:String
    match(multiplier):
        HIT_MULTIPLIER: label = HIT_LABEL
        CRIT_MULTIPLIER: label = CRIT_LABEL
        0.0: label = MISSED_LABEL

    _battle.resolve_attack(multiplier, label)
    
    # Delay removing from UI so the player can see the result.
    _free_timer.start(1)


func start():
    _is_running = true


func _on_FreeTimer_timeout():
    self.queue_free()


func _get_value():
    pass


func _get_multiplier() -> float:
    return 1.0
    

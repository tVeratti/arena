extends KinematicBody2D

class_name Unit

const SELECTED = "SELECTED"
const HOVERED = "HOVERED"
const TARGETED = "TARGETED"
const IDLE = "IDLE"

var Colors = preload("res://Character/Colors.gd")
var CombatText = preload("res://Battle/CombatText.tscn")

var shader_outline = preload("res://Assets/outline.shader")

# Movement
var speed:float = 500.0
var path:PoolVector2Array = [] setget set_path
var path_end:Vector2
var path_index:int = 0
var coord:Vector2 setget , _get_coord
var map

var character:Character
var is_enemy:bool
var color:Color
var state:String
var prev_state:String
var facing:Vector2

var _action_state:String

var _is_target_locked:bool
var _prev_target_locked:bool
var _lock_state:String

onready var rig = $Viewport/Rig
onready var health = $Status/HealthBar
onready var anchor = $PopupAnchor
onready var sprite = $Sprite

onready var click_collider = $ClickCollision
var allow_selection:bool = true
var allow_targeting:bool = false

var _combat_text_showing:bool = false
var _combat_text_queue:Array = []


func _ready():
    set_physics_process(false)
    set_state(IDLE)
    
    SignalManager.connect("health_changed", self, "_on_health_changed")
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")
    SignalManager.connect("ranked_up", self, "_on_ranked_up")
    
    rig.set_textures(character.textures)
    rig.set_colors(character.colors)
    if is_enemy:
        rig.set_facing("BACK")
        facing = get_facing("BACK", 1)
    else:
        rig.set_facing("FRONT")
        facing = get_facing("FRONT", 1)


func setup(tile_position, map, character, is_enemy = false):
    position = tile_position
    path_end = tile_position
    self.map = map
    self.character = character
    self.is_enemy = is_enemy
    self.color = Colors.ENEMY if character.is_enemy else Colors.FRIENDLY
    
    $Status/HealthBar.setup(character, self.color)
    $Status/Name.text = character.name


func _physics_process(delta):
    var target:Vector2 = path[path_index]
    var velocity:Vector2
    var distance:float = position.distance_to(target)
    
    if distance > 5:
        velocity = (target - position).normalized() * speed
        move_and_slide(velocity)
    
    elif path_index < path.size() - 1:
        path_index += 1
        turn_rig(path[path_index])
        
    else:
        SignalManager.emit_signal("unit_movement_done")
        set_physics_process(false)


func activate():
    set_state(SELECTED)
    SignalManager.emit_signal("_on_unit_focused", self)


func deactivate():
    set_state(IDLE)


func lock_targeted(action_state = Action.ATTACK):
    _prev_target_locked = _is_target_locked
    _is_target_locked = true
    _lock_state = action_state
    set_state(TARGETED)


func unlock_targeted():
    _prev_target_locked = _is_target_locked
    _is_target_locked = false
    _lock_state = Action.WAIT
    set_state(IDLE)


func set_state(next_state):
    if next_state == state and _prev_target_locked == _is_target_locked:
        return
    
    # ShaderMaterial is shared by all instances,
    # so it is necessary to create a new one each time.
    var material = ShaderMaterial.new()
    material.shader = shader_outline
    material.set_shader_param("outline_width", 10.0)
    
    var outline_color = Color(0,0,0,0);
    
    match(next_state):
        SELECTED, TARGETED:
            outline_color = color
            #health.show()
        HOVERED:
            outline_color = get_color(_action_state, color)
            #health.show()
        IDLE:
            if !_is_target_locked:
                rig.set_animation("Idle")
                #health.try_hide()
    
    outline_color = get_color(_lock_state, outline_color)
    
    material.set_shader_param("outline_color", outline_color)
    sprite.material = material
    
    prev_state = state
    state = next_state


func get_color(state, current_color):
    var outline_color = current_color
    match(state):
        Action.ANALYZE:
            outline_color = Colors.CHALLENGE
        Action.ATTACK:
            outline_color = color
    
    return outline_color


func turn_rig(target_world_position):
    var direction = (target_world_position - position).normalized()
    var rig_facing = ""
    var rig_scale = 0.5
    var x = 1 if direction.x > 0 else -1
    var y = 1 if direction.y > 0 else -1
    
    if (x > 0 and y < 0) or (x < 0 and y < 0):
        rig_facing = "BACK"
    else:
        x *= -1
        rig_facing = "FRONT"
    
    rig.set_facing(rig_facing)
    sprite.set_scale(Vector2(x * rig_scale, rig_scale))
    
    facing = get_facing(rig_facing, x)


func get_facing(rig_facing:String, x_scale:int) -> Vector2:
    if rig_facing == "FRONT":
        if x_scale == -1: return Facing.RIGHT
        else: return Facing.DOWN
    else:
        if x_scale == -1: return Facing.LEFT
        else: return Facing.UP


func set_animation(state:String):
    rig.set_animation(state)


func set_path(value:PoolVector2Array):
    var valid_path = []
    path_index = 0
    
    # Check that the unit's character has enough speed
    # to complete the full movement.
    for i in range(value.size()):
        if character.speed >= i:
            valid_path.append(value[i])

    if valid_path.size() > 0:
        path = valid_path
        path_end = valid_path[valid_path.size() - 1]
        set_physics_process(true)


func show_combat_text(combat_text):
    if _combat_text_showing:
        _combat_text_queue.append(combat_text)
        _combat_text_showing = true
    else: anchor.add_child(combat_text)


func show_damage(value, label, color):
    # Render the damage done...
    var damage_text = CombatText.instance()
    damage_text.setup(value, label, color)
    show_combat_text(damage_text)    


func _get_coord() -> Vector2:
    return map.world_to_map(position)


func _on_health_changed(target):
    if character == target and not target.is_alive:
        # Start the death timer (allow animations to finish)
        $DeathTimer.start(2)


func _on_Timer_timeout():
    # I die... die.... DIE!!
        queue_free()


func _on_Character_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
        if allow_selection:
            SignalManager.emit_signal("unit_focused", self)
        elif allow_targeting:
            SignalManager.emit_signal("unit_targeted", self)


func _on_battle_state_updated(action_state):
    _action_state = action_state
    
    # Disable the click collision so that the attack telegraph
    # does not detect the oversized collision shape.
    allow_selection = action_state == Action.WAIT
    allow_targeting = action_state == Action.ATTACK or action_state == Action.ANALYZE
    click_collider.disabled = action_state == Action.MOVE


func _on_Character_mouse_entered():
    SignalManager.emit_signal("unit_hovered", self)
    set_state(HOVERED)


func _on_Character_mouse_exited():
    SignalManager.emit_signal("unit_hovered", null)
    set_state(prev_state)


func _on_ranked_up(character, stat):
    if character != self.character or character.is_enemy: return
    
    var rank_text = CombatText.instance()
    rank_text.setup(stat.name, "RANK %s" % stat.rank, Colors.FRIENDLY)
    show_combat_text(rank_text)


func _on_CombatTextQueue_timeout():
    if _combat_text_queue.size() > 0:
        var current_text = _combat_text_queue.pop_front()
        anchor.add_child(current_text)
    else: _combat_text_showing = false

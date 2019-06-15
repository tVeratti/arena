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
var coord:Vector2

var character:Character
var is_enemy:bool
var color:Color
var state:String
var prev_state:String

var is_target_locked:bool
var prev_target_locked:bool

onready var rig = $Viewport/Rig
onready var health = $HealthBar
onready var anchor = $PopupAnchor
onready var sprite = $Sprite

onready var click_collider = $ClickCollision
var allow_selection:bool = true
var allow_targeting:bool = false


func _ready():
    set_physics_process(false)
    set_state(IDLE)
    
    SignalManager.connect("health_changed", self, "_on_health_changed")
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")
    
    rig.set_textures(character.textures)
    rig.set_colors(character.colors)
    if is_enemy:
        rig.set_facing("BACK")


func setup(tile_position, coord, character, is_enemy = false):
    position = tile_position
    path_end = tile_position
    self.coord = coord
    self.character = character
    self.is_enemy = is_enemy
    self.color = Colors.ENEMY if character.is_enemy else Colors.FRIENDLY
    
    $HealthBar.setup(character, self.color)


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
    SignalManager.emit_signal("character_selected", character)


func deactivate():
    set_state(IDLE)


func lock_targeted():
    prev_target_locked = is_target_locked
    is_target_locked = true


func unlock_targeted():
    prev_target_locked = is_target_locked
    is_target_locked = false


func set_state(next_state):
    if next_state == state and prev_target_locked == is_target_locked:
        return
    
    # ShaderMaterial is shared by all instances,
    # so it is necessary to create a new one each time.
    var material = ShaderMaterial.new()
    material.shader = shader_outline
    material.set_shader_param("outline_width", 10.0)
    
    var outline_color = color;
    match(next_state):
        SELECTED, HOVERED, TARGETED:
            health.show()
        IDLE:
            if !is_target_locked:
                outline_color = Color(0,0,0,0)
                rig.set_animation("Idle")
                health.try_hide()
    
    material.set_shader_param("outline_color", outline_color)
    sprite.material = material
    
    prev_state = state
    state = next_state


func turn_rig(target_world_position):
    var direction = (target_world_position - position).normalized()
    var rig_scale = 0.5
    var x = 1 if direction.x > 0 else -1
    var y = 1 if direction.y > 0 else -1
    
    if (x > 0 and y < 0) or (x < 0 and y < 0):
        rig.set_facing("BACK")
    else:
        x *= -1
        rig.set_facing("FRONT")
    
    sprite.set_scale(Vector2(x * rig_scale, rig_scale))


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


func show_damage(value, label):
    # Render the damage done...
    var damage_text = CombatText.instance()
    anchor.add_child(damage_text)
    damage_text.setup(value, label)


func _on_health_changed(target):
    if character == target and not target.is_alive:
        # Start the death timer (allow animations to finish)
        $Timer.start(2)


func _on_Timer_timeout():
    # I die... die.... DIE!!
        queue_free()


func _on_Character_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
        if allow_selection:
            SignalManager.emit_signal("character_selected", character)
        elif allow_targeting:
            SignalManager.emit_signal("unit_targeted", self)


func _on_battle_state_updated(action_state):
    # Disable the click collision so that the attack telegraph
    # does not detect the oversized collision shape.
    allow_selection = action_state == Action.WAIT
    allow_targeting = action_state == Action.ATTACK or action_state == Action.ANALYZE
    click_collider.disabled = action_state == Action.MOVE


func _on_Character_mouse_entered():
    set_state(HOVERED)


func _on_Character_mouse_exited():
    set_state(prev_state)

extends KinematicBody2D

class_name Unit

const ACTIVE = "ACTIVE"
const TARGETED = "TARGETED"
const IDLE = "IDLE"

var shader_darken = preload("res://Assets/darken.shader")
var shader_lighten = preload("res://Assets/lighten.shader")
var shader_red = preload("res://Assets/red.shader")

# Movement
var speed:float = 500.0
var path = PoolVector2Array() setget set_path
var path_end:Vector2
var path_index:int = 0

var character:Character
var is_enemy:bool
var state:String

var sprite_sheet
onready var rig = $Rig
onready var health = $HealthBar


func _ready():
    set_physics_process(false)
    set_state(IDLE)
    
    SignalManager.connect("health_changed", self, "_on_health_changed")
    # rig.get_node("AnimationPlayer").play("base")
    
    rig.set_textures(character.textures)


func setup(tile_position, character, is_enemy = false):
    position = tile_position
    path_end = tile_position
    self.character = character
    self.is_enemy = is_enemy
    
    
    $HealthBar.setup(character)
    
    #SignalManager.connect("health_changed", self, "_on_health_changed")


func _physics_process(delta):
    var target:Vector2 = path[path_index]
    var velocity:Vector2
    var distance:float = position.distance_to(target)
    
    if distance > 5:
        velocity = (target - position).normalized() * speed
        move_and_slide(velocity)
    
    elif path_index < path.size() - 1:
        path_index += 1
        
    else:
        SignalManager.emit_signal("unit_movement_done")
        set_physics_process(false)


func activate():
    set_state(ACTIVE)
    SignalManager.emit_signal("character_selected", character)


func deactivate():
    set_state(IDLE)


func target(is_targeted):
    set_state(TARGETED if is_targeted else IDLE)


func set_state(next_state):
    if next_state == state:
        return
    
    # ShaderMaterial is shared by all instances,
    # so it is necessary to create a new one each time.
    var material = ShaderMaterial.new()
    match(next_state):
        ACTIVE:
            material.shader = shader_lighten
        TARGETED:
            material.shader = shader_red
        IDLE:
            #TEMP ENEMY SHADER
            material.shader = shader_darken if character.is_enemy else null 
        
    rig.material = material
    state = next_state


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
            SignalManager.emit_signal("character_selected", character)

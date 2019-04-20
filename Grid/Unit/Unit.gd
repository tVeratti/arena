extends KinematicBody2D

class_name Unit

var white_outline = preload("res://Assets/outline_white.shader")
var red_outline = preload("res://Assets/outline_red.shader")

# Movement
var speed:float = 300.0
var path = PoolVector2Array() setget set_path
var path_end:Vector2
var path_index:int = 0

var character:Character
var is_enemy:bool
var is_active:bool

onready var sprite = $Sprite
onready var health = $HealthBar


func _ready():
    set_physics_process(false)
    SignalManager.connect("health_changed", self, "_on_health_changed")


func setup(tile_position, character, is_enemy = false):
    position = tile_position
    path_end = tile_position
    self.character = character
    self.is_enemy = is_enemy
    
    $Sprite.texture = character.unit_texture
    $HealthBar.setup(character)
    
    #SignalManager.connect("health_changed", self, "_on_health_changed")


func _physics_process(delta):
    var target:Vector2 = path[path_index]
    var velocity:Vector2
    var distance:float = position.distance_to(target)
    
    if distance > 5:
        velocity = (target - position).normalized() * speed
        move_and_slide(velocity)
        #position = position.linear_interpolate(current, delta * speed)
        #position = Vector2(\
            #lerp(position.x, current.x, delta * speed),\
            #lerp(position.y, current.y, delta * speed))
    
    elif path_index < path.size() - 1:
        # Start moving to the next point on the path
        path_index += 1
        
    else:
        #position = current
        SignalManager.emit_signal("unit_movement_done")
        set_physics_process(false)


func activate():
    set_outline(true)
    SignalManager.emit_signal("character_selected", character)


func deactivate():
    set_outline(false)


func set_outline(value = false):
    if value == is_active:
        return
    
    if value:
        # ShaderMaterial is shared by all instances,
        # so it is necessary to create a new one each time.
        var material = ShaderMaterial.new()
        material.shader = red_outline if is_enemy else white_outline
        sprite.material = material
    else:
        sprite.material.shader = null
    
    is_active = value


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

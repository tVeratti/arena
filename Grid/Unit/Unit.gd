extends Node2D

class_name Unit

var white_outline = preload("res://Assets/outline_white.shader")
var red_outline = preload("res://Assets/outline_red.shader")

# Movement
var speed:float = 200.0
var path = PoolVector2Array() setget set_path
var path_end:Vector2

var character:Character
var is_enemy:bool
var is_active:bool

onready var sprite = $Sprite
onready var health = $HealthBar


func _ready():
    set_process(false)
    SignalManager.connect("health_changed", self, "_on_health_changed")


func setup(tile_position, character, is_enemy = false):
    position = tile_position
    path_end = tile_position
    self.character = character
    self.is_enemy = is_enemy
    
    $Sprite.texture = character.unit_texture
    $HealthBar.setup(character)
    
    #SignalManager.connect("health_changed", self, "_on_health_changed")


func _process(delta):
    var move_distance = speed * delta
    move_along_path(move_distance)


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


func move_along_path(distance):
    var start = position

    if path.size() == 0:
        set_process(false)
        SignalManager.emit_signal("unit_movement_done")
        return
    
    for i in range(path.size()):
        var current = path[0]
        var distance_to_next = start.distance_to(current)
        
        if distance <= distance_to_next and distance >= 0.0:
            position = start.linear_interpolate(current, distance / distance_to_next)
            break
        elif distance < 0.0:
            position = current
            set_process(false)
            SignalManager.emit_signal("unit_movement_done")
            break
        
        distance -= distance_to_next
        start = current
        path.remove(0)


func set_path(value:PoolVector2Array):
    var valid_path = []
    
    # Check that the unit's character has enough speed
    # to complete the full movement.
    for i in range(value.size()):
        if character.speed >= i:
            valid_path.append(value[i])

    if valid_path.size() > 0:
        path = valid_path
        path_end = valid_path[valid_path.size() - 1]
        set_process(true)


func _on_health_changed(target):
    if character == target and not target.is_alive:
        # Start the death timer (allow animations to finish)
        $Timer.start(2)


func _on_Timer_timeout():
    # I die... die.... DIE!!
        queue_free()

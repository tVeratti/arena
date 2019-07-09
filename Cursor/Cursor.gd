extends Area2D

var Action = load("res://Battle/Action.gd")

var default_icon = preload("res://Cursor/textures/default.png")
var move_icon = preload("res://Cursor/textures/move.png")
var attack_icon = preload("res://Cursor/textures/attack.png")
var analyze_icon = preload("res://Cursor/textures/eye.png")

var _prev_state = Action.WAIT
var _point_center:bool = false

onready var sprite = $Sprite


func _ready():
    # Hide default cursor
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    sprite.texture = default_icon
    
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")


func _exit_tree():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta):
    var mouse_position = get_global_mouse_position()
    position = mouse_position
    
    if _point_center:
        var screen_center = get_viewport_rect().size / 2
        sprite.rotation = mouse_position.angle_to_point(screen_center) - 1
    else:
        sprite.rotation = 0


func _on_battle_state_updated(next_state):
    _point_center = false
    match(next_state):
        Action.MOVE: sprite.texture = move_icon
        Action.ATTACK: sprite.texture = attack_icon
        Action.FREEZE:
            sprite.texture = default_icon
            if _prev_state == Action.ATTACK:
                _point_center = true
        Action.ANALYZE: sprite.texture = analyze_icon
        _: sprite.texture = default_icon
    
    _prev_state = next_state
            
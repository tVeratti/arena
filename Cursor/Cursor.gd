extends Area2D

var Action = load("res://Battle/Action.gd")

var default_icon = preload("res://Cursor/textures/default.png")
var move_icon = preload("res://Cursor/textures/move.png")
var attack_icon = preload("res://Cursor/textures/attack.png")
var analyze_icon = preload("res://Cursor/textures/eye.png")

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


func _on_battle_state_updated(state):
    match(state):
        Action.MOVE: sprite.texture = move_icon
        Action.ATTACK: sprite.texture = attack_icon
        Action.ANALYZE: sprite.texture = analyze_icon
        _: sprite.texture = default_icon
            
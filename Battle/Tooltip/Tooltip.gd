extends Control

var Comparison = load("res://Battle/Tooltip/Comparison.tscn")

const MOUSE_OFFSET = 44

var hovered_unit:Unit
var hovered_unit_previous:Unit

var focused_unit:Unit
var action_state:String

onready var container:MarginContainer = $Container
onready var animation:AnimationPlayer = $AnimationPlayer


func _ready():
    SignalManager.connect("unit_focused", self, "_on_unit_focused")
    SignalManager.connect("unit_hovered", self, "_on_unit_hovered")
    SignalManager.connect("unit_targeted", self, "_on_unit_targeted")
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")


func _input(event):
    if event is InputEventMouseMotion:
        rect_position = Vector2(
            event.position.x + MOUSE_OFFSET,
            event.position.y)


func update_data():
    match(action_state):
        Action.ATTACK, Action.ANALYZE:
            if hovered_unit != null and focused_unit != null:
                show_comparison()
            else: reset()

        _: reset()


func show_comparison():
    reset()
    
    var comparison = Comparison.instance()
    comparison.setup(hovered_unit, focused_unit)
    container.add_child(comparison)
    animation.play("Show")
    show()
    

func reset():
    hide()
    animation.stop()
    for child in container.get_children():
        child.free()


# Signal Listeners

func _on_unit_focused(unit):
    if unit != focused_unit:
        focused_unit = unit
        update_data()


func _on_unit_hovered(unit):
    if unit != hovered_unit:
        hovered_unit_previous = hovered_unit
        hovered_unit = unit
        update_data()


func _on_unit_targeted():
    reset()


func _on_battle_state_updated(state):
    action_state = state
    update_data()
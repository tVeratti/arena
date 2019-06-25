extends Control

const MOUSE_OFFSET = 44

onready var target_name:Label = $MarginContainer/MarginContainer/Rows/Name
onready var anim:AnimationPlayer = $AnimationPlayer

# StatDifference Nodes
var speed
var toughness
var power


func _ready():
    var stats = $MarginContainer/MarginContainer/Rows/MarginContainer/Stats
    speed = stats.get_node("Speed")
    toughness = stats.get_node("Toughness")
    power = stats.get_node("Power")


func _input(event):
    if event is InputEventMouseMotion:
        rect_position = Vector2(
            event.position.x + MOUSE_OFFSET,
            event.position.y)


func set_characters(target:Unit, attacker:Unit):
    target_name.text = target.character.name
    speed.set_data("Speed", target.character.speed, attacker.character.speed)
    toughness.set_data("Toughness", target.character.toughness, attacker.character.toughness)
    power.set_data("Power", target.character.power, attacker.character.power)
    anim.play("show")
    
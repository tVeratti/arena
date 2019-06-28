extends Control

var target:Unit
var attacker:Unit

onready var target_name:Label = $Container/Rows/Name

# StatDifference Nodes
var speed
var toughness
var power


func setup(target:Unit, attacker:Unit):
    self.target = target
    self.attacker = attacker


func _ready():
    var stats = $Container/Rows/MarginContainer/Stats
    speed = stats.get_node("Speed")
    toughness = stats.get_node("Toughness")
    power = stats.get_node("Power")
    apply_data()


func apply_data():
    target_name.text = target.character.name
    speed.set_data("Speed", target.character.speed, attacker.character.speed)
    toughness.set_data("Toughness", target.character.toughness, attacker.character.toughness)
    power.set_data("Power", target.character.power, attacker.character.power)
    
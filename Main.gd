extends Node2D

var Battle = preload("res://Battle/Battle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    var heroes = [
        Character.new("Valla"),
        Character.new("Valeera"),
        Character.new("Ashe")
    ]
    
    var enemies = [
        Character.new("Sovereign"),
        Character.new("Caleb"),
        Character.new("Detlaff")
    ]
    
    var new_battle = Battle.instance()
    new_battle.setup(heroes, enemies)
    add_child(new_battle)

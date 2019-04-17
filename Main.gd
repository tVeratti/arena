extends Node2D

var Battle = preload("res://Battle/Battle.tscn")

func _init():
    ScreenManager.main = self
    
    
# Called when the node enters the scene tree for the first time.
func _ready():
    var battle = {
        "heroes": [
            Character.new("Valla"),
            Character.new("Valeera"),
            Character.new("Ashe")
        ],
        "enemies": [
            Character.new("Sovereign", true),
            Character.new("Caleb", true),
            Character.new("Detlaff", true)
        ]
    }
    
    ScreenManager.change_to(Scenes.BATTLE_ENTER, battle)

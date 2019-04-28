extends Node2D

var Battle = preload("res://Battle/Battle.tscn")

func _init():
    ScreenManager.main = self
    
    
# Called when the node enters the scene tree for the first time.
func _ready():
    # start_game()
    ScreenManager.change_to(Scenes.__DEV_GENERATOR)


func start_game():
    var battle = {
        "heroes": [
            Character.new("Carol"),
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

extends Node2D

var Battle = preload("res://Battle/Battle.tscn")

func _init():
    ScreenManager.main = self
    

func _ready():
    start_game()
    #ScreenManager.change_to(Scenes.__DEV_GENERATOR)


func start_game():
    var battle = {
        "heroes": [
            Character.new("Carol"),
            Character.new("Valeera"),
            Character.new("Ashe"),
            Character.new("Christophe"),
        ],
        "enemies": [
            Character.new("Sovereign", true),
            Character.new("Caleb", true),
            Character.new("Beastie", true),
            Character.new("Gracie", true),
        ]
    }
    
    ScreenManager.change_to(Scenes.BATTLE_ENTER, battle)

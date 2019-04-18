extends Node

class_name AI

func take_action(action):
    match(action):
        Action.MOVE:
            decide()
        Action.ATTACK:
            attack()


func decide():
    pass


func move():
    pass


func attack():
    pass
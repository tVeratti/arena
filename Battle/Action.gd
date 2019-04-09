extends Object

class_name Action

const MOVE = "MOVE"
const ATTACK = "ATTACK"

var type:String

func _init(type:String):
    self.type = type
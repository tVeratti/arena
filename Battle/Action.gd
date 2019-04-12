extends Object

class_name Action

const MOVE = "MOVE"
const ATTACK = "ATTACK"
const ANALYZE = "ANALYZE"
const WAIT = "WAIT"

var type:String

func _init(type:String):
    self.type = type
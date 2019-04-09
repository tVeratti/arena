extends Object

class_name Character

var id:String
var name:String
var speed:int = 1


func _init(name):
    self.name = name
    self.id = "%s_%s" % [name, randi()]
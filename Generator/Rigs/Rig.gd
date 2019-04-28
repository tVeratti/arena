extends Node2D

const FRONT = "FRONT"
const BACK = "BACK"

onready var back_node = $Back/parts
onready var front_node = $Front/parts

var facing:String = FRONT
var textures:Dictionary


func _ready():
    pass
    #back_node.hide()
    # $AnimationPlayer.play("idle")


func set_textures(textures:Dictionary):
    self.textures = textures
    
    set_facing_textures(front_node)
    set_facing_textures(back_node)
    

func set_facing_textures(parts):
    for part in parts.get_children():
        part.texture = textures[part.name]


func set_facing(facing:String):
    self.facing = facing

    match(facing):
        FRONT:
            back_node.hide()
            front_node.show()
        BACK:
            back_node.show()
            front_node.hide()
extends Node2D

const FRONT = "FRONT"
const BACK = "BACK"

onready var back_node = $Back/parts
onready var front_node = $Front/parts

var facing:String = FRONT
var textures:Dictionary


func _ready():
    back_node.hide()

    # $AnimationPlayer.play("idle")


func set_textures(textures:Dictionary):
    self.textures = textures
    
    set_facing_textures(front_node)
    set_facing_textures(back_node)
    

func set_facing_textures(parts):
    var region_padding = 100
    for part in parts.get_children():
        if part is Sprite:
            var rect = part.region_rect
            part.region_rect = Rect2(\
                rect.position.x - region_padding, \
                rect.position.y - region_padding, \
                rect.size.x + region_padding, \
                rect.size.y + region_padding)
            part.texture = textures[part.name]
            
            if part.get_child_count() > 0:
                set_facing_textures(part)


func set_facing(facing:String):
    self.facing = facing

    match(facing):
        FRONT:
            back_node.hide()
            front_node.show()
        BACK:
            back_node.show()
            front_node.hide()
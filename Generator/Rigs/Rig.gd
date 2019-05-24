extends Node2D

var Colors = load("res://Character/Colors.gd")

const FRONT = "FRONT"
const BACK = "BACK"

const ANIM_IDLE = "Idle"
const ANIM_ATTACK = "Attack"

onready var back_node = $Back/parts
onready var front_node = $Front/parts

var facing:String = FRONT
var textures:Dictionary


func _ready():
    back_node.hide()

    # $AnimationPlayer.play("idle")


func set_colors(colors:Dictionary):
    var new_material = ShaderMaterial.new()
    Colors.set_shader_params(new_material, colors)
    material = new_material


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
                rect.position.x, #- region_padding, \
                rect.position.y, #- region_padding, \
                rect.size.x, #+ region_padding, \
                rect.size.y) #+ region_padding)
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


func set_animation(anim:String):
    $Front.get_node("AnimationPlayer").play(anim)
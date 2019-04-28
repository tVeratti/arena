extends Node2D

var Textures = preload("res://Character/Textures.gd")
var PARTS = preload("res://Generator/Part.gd").PARTS

export var texture_a:Texture = Textures.TEMPLATE_01
export var texture_b:Texture = Textures.TEMPLATE_02
export var texture_c:Texture = Textures.TEMPLATE_03

onready var source = $Source

var _source:Dictionary

func _ready():
    generate()


func generate():
    var textures = {}
    for part in PARTS:
        textures[part] = random_texture()
    
    source.set_textures(textures)


func random_texture():
    var result = int(rand_range(0.0, 3.0))
    match(result):
        0: return texture_a
        1: return texture_b
        2: return texture_c


func _on_Randomize_pressed():
    randomize()
    generate()


func _on_Back_pressed():
    source.set_facing("BACK")


func _on_Front_pressed():
    source.set_facing("FRONT")

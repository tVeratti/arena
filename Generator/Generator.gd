extends Node2D

var PARTS = preload("res://Generator/Part.gd").PARTS

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
    var index = int(rand_range(0.0, 3.0))
    return Resources.spritesheets[index]


func _on_Randomize_pressed():
    randomize()
    generate()


func _on_Back_pressed():
    source.set_facing("BACK")


func _on_Front_pressed():
    source.set_facing("FRONT")

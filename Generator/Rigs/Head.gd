extends Node2D

var Colors = load("res://Character/Colors.gd")

onready var _torso = $torso
onready var _head = $head
onready var _hair = $hair


func set_character(character:Character):
    # Base Textures
    _torso.texture = character.textures["torso"]
    _head.texture = character.textures["head"]
    _hair.texture = character.textures["hair"]
    
    #Colors
    var colors_material = ShaderMaterial.new()
    var colors = character.colors
    Colors.set_shader_params(colors_material, colors)
    material = colors_material

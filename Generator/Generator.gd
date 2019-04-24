extends Node2D

var TEXTURES = preload("res://Character/TEXTURES.gd")

export var texture_a:Texture = TEXTURES.TEMPLATE_01
export var texture_b:Texture = TEXTURES.TEMPLATE_02
export var texture_c:Texture = TEXTURES.TEMPLATE_03

onready var target = $Target

var _source:Dictionary

func _ready():
    _source = $Source.get_sprite_dictionary()
    generate()


func generate():
    for part_key in _source.keys():
        var part = _source[part_key]
        var part_node:Polygon2D = target.find_node(part_key)
        
        if part_node is Polygon2D:
            part_node.texture = random_texture()
            part_node.polygon = part.polygon


func random_texture():
    var result = int(rand_range(0.0, 3.0))
    match(result):
        0: return texture_a
        1: return texture_b
        2: return texture_c

func _on_Save_pressed():
    pass
    #var part_json = _source.to_JSON()
    #var save_parts = File.new()
    #save_parts.open("user://new.json", File.WRITE)
    #save_parts.store_line(part_json)
    
    #save_parts.close()


func _on_Randomize_pressed():
    randomize()
    generate()

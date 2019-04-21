extends Node2D

var TEXTURES = preload("res://Character/TEXTURES.gd")


onready var generated_sprites = $Character/Sprites

var _source:Part

func _ready():
    _source = $Source.get_sprite_details()
    generate()


func generate():
    for part in _source.children:
        var part_sprite = Sprite.new()
        part_sprite.texture = TEXTURES.BASE_HAPPY #part.texture
        part_sprite.region_enabled = true
        part_sprite.region_rect = part.region
        part_sprite.transform = part.transform
        generated_sprites.add_child(part_sprite)


func _on_Save_pressed():
    var part_json = _source.to_JSON()
    var save_parts = File.new()
    save_parts.open("user://new.json", File.WRITE)
    save_parts.store_line(part_json)
    
    save_parts.close()

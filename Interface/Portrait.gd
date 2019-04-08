extends Control

var outline_shader = preload("res://outline.shader")

onready var Img = $Layout/Image

func setup(character):
    $Layout/Name.text = String(character.name)
    
func set_outline(value):
    if value:
        # ShaderMaterial is shared by all instances,
        # so it is necessary to create a new one each time.
        var material = ShaderMaterial.new()
        material.shader = outline_shader
        Img.material = material
    else:
        Img.material.shader = null

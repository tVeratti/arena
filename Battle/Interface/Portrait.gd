extends Control

var outline_shader = preload("res://outline.shader")

onready var Img = $Layout/Image

var character_id:String

func setup(character):
    character_id = character.id
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


func _on_Portrait_gui_input(event):
    if event is InputEventMouseButton and event.is_pressed():
        print("portrait handled")
        get_tree().set_input_as_handled()

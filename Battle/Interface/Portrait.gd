extends Control

var outline_shader = preload("res://outline.shader")

onready var image = $Layout/Image

var character:Character


func setup(character):
    # Before _ready
    self.character = character
    $Layout/Name.text = String(character.name)


func set_outline(value):
    if value:
        # ShaderMaterial is shared by all instances,
        # so it is necessary to create a new one each time.
        var material = ShaderMaterial.new()
        material.shader = outline_shader
        image.material = material
    else:
        image.material.shader = null


func _on_Portrait_gui_input(event):
    if event is InputEventMouseButton and event.is_pressed():
        get_tree().set_input_as_handled()
        SignalManager.emit_signal("character_selected", character)
        

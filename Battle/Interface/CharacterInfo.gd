extends Control

var colors_shader = preload("res://Assets/colors.shader")

onready var _head = $Head/head
onready var _hair = $Head/hair
onready var _name = $Layout/Details/Name
onready var _speed = $Layout/Details/Speed
onready var _toughness = $Layout/Details/Toughness
onready var _power = $Layout/Details/Power
onready var _health = $Health


func _ready():
    SignalManager.connect("character_selected", self, "_on_character_selected")
    hide()
    

func _on_character_selected(character:Character):
    if character != null:
        show()
    else:
        hide()

    _head.texture = character.textures["head"]
    _hair.texture = character.textures["hair"]
    
    var new_material = ShaderMaterial.new()
    new_material.shader = colors_shader
    
    var colors = character.colors
    var darken_amount = 0.4
    new_material.set_shader_param("hair_normal", colors.hair)
    new_material.set_shader_param("hair_shadow", colors.hair.darkened(darken_amount))
    
    new_material.set_shader_param("skin_normal", colors.skin)
    new_material.set_shader_param("skin_shadow", colors.skin.darkened(darken_amount))
    
    $Head.material = new_material
    
    _name.text = character.name
    _speed.text = "Speed: %s" % character.speed
    _toughness.text = "Toughness: %s" % character.toughness
    _power.text = "Power: %s" % character.power
    _health.value = \
        character.health.value_current / \
        character.health.value_maximum * 100
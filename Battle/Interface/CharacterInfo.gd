extends Control

onready var _image = $Layout/Image
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

    _image.texture = character.portrait_texture
    _name.text = character.name
    _speed.text = "Speed: %s" % character.speed
    _toughness.text = "Toughness: %s" % character.toughness
    _power.text = "Power: %s" % character.power
    _health.value = \
        character.health.value_current / \
        character.health.value_maximum * 100
extends Control

var Colors = load("res://Character/Colors.gd")
var outline_shader = load("res://Assets/outline.shader")

const BASIC = "BASIC"
const FULL = "FULL"

var _unit;
var _type:String = BASIC

# Head
onready var _sprite_head = $Layout/HeadLayout/Head
onready var _viewport_head = $Viewport/Head

# Stats
onready var _details = $Layout/Details
onready var _name = $Layout/Details/Name
onready var _speed = $Layout/Details/Speed
onready var _toughness = $Layout/Details/Toughness
onready var _power = $Layout/Details/Power
onready var _acuity = $Layout/Details/Acuity
onready var _rating = $Layout/Details/Rating
onready var _health = $Layout/HeadLayout/Health

func _init():
    hide()

func _ready():
    SignalManager.connect("unit_focused", self, "_on_unit_focused")
    SignalManager.connect("stat_changed", self, "_on_stat_changed")


func setup(unit:Unit, type:String = FULL):
    _unit = unit
    _type = type
    
    if unit != null:
        update_stats(unit.character)


func set_unit(unit:Unit):
    if _type == FULL and unit != null:
        _unit = unit
        update_stats(unit.character)
    elif unit == _unit and unit != null:
        set_outline(unit.character)
    else:
         clear_outline()


func set_character(character:Character):
    update_stats(character)


func update_stats(character:Character):
    # Update textures & colors
    _viewport_head.set_character(character)
    
    # Stats
    if _type == FULL:
        _name.text = character.name
        _speed.text = "Speed: %s" % character.speed
        _toughness.text = "Toughness: %s" % character.toughness
        _power.text = "Power: %s" % character.power
        _acuity.text = "Acuity: %s" % character.acuity
        _health.tint_progress = Colors.ENEMY if character.is_enemy else Colors.FRIENDLY
        _health.value = \
            character.health.value_current / \
            character.health.value_maximum * 100
        
        # Rating stars
        var rating = ""
        for star in range(character.rating):
            rating += "*"
        
        _rating.text = rating
        _details.show()
    
    else:
        _details.hide()
    
    show()


func set_outline(character:Character, active:bool = false):
    var outline_color = Colors.ENEMY if character.is_enemy else Colors.FRIENDLY
    var outline_material:ShaderMaterial = ShaderMaterial.new()
    outline_material.shader = outline_shader
    outline_material.set_shader_param("outline_color", outline_color)
    outline_material.set_shader_param("outline_width", 3)
    _sprite_head.material = outline_material


func clear_outline():
    _sprite_head.material = null


func _on_unit_focused(unit:Unit):
    set_unit(unit)


func _on_stat_changed(character):
    if character == _unit.character:
        update_stats(character)


func _on_CharacterInfo_gui_input(event):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.is_pressed():
        SignalManager.emit_signal("unit_focused", _unit)

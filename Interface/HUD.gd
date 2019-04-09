extends CanvasLayer

var Portrait = preload("res://Interface/Portrait.tscn")

onready var frames = $Layout/Rows/Columns/Characters/Frames
onready var distance = $Layout/Rows/Columns/Distance
onready var active_portrait = $Layout/Rows/Columns/MarginContainer/ActivePortrait

onready var portraits = {}

func _ready():
    render_battle()
    
    SignalManager.connect("tile_focused", self, "_on_tile_focused")
    SignalManager.connect("tile_selected", self, "_on_tile_selected")

func render_battle():
    var battle = get_parent()
    
    # Render character portraits
    for hero in battle.heroes:
        var portrait = Portrait.instance()
        portrait.setup(hero)
        frames.add_child(portrait)
        
        # Save a reference for future selections.
        portraits[hero.id] = portrait


func _on_tile_focused(tile, path):    
    pass
    
func _on_tile_selected(tile, unit):
    for id in portraits.keys():
        var portrait = portraits[id]
        var is_active = unit != null and unit.character.id == id
        portrait.set_outline(is_active)
        
        if is_active:
            active_portrait.setup(unit.character)
            

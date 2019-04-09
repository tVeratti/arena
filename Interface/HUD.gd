extends CanvasLayer

var Portrait = preload("res://Interface/Portrait.tscn")

onready var frames = $Layout/Rows/Columns/Characters/Frames
onready var distance = $Layout/Rows/Columns/Distance
onready var active_portrait = $Layout/Rows/Columns/MarginContainer/ActivePortrait

onready var portraits = {}

var _battle

func _ready():
    _battle = get_parent()
    render_portraits(_battle.current_turn.characters_awaiting)
    
    SignalManager.connect("tile_focused", self, "_on_tile_focused")
    SignalManager.connect("tile_selected", self, "_on_tile_selected")
    SignalManager.connect("turn_updated", self, "_on_turn_updated")

func render_portraits(characters):
    var character_ids = []
    
    # Render character portraits
    for character in characters:
        character_ids.append(character.id)
        
        if portraits.has(character.id):
            continue
        
        # Create new portrait instance...
        var portrait = Portrait.instance()
        portrait.setup(character)
        frames.add_child(portrait)
        
        # Save a reference for future selections.
        portraits[character.id] = portrait
    
    # Remove any frames tied to characters that are
    # no longer in the list to be rendered.
    for portrait in frames.get_children():
        if not character_ids.has(portrait.character_id):
            portraits.erase(portrait.character_id)
            portrait.queue_free()


func _on_tile_focused(tile, path):    
    pass


func _on_tile_selected(tile, unit):
    for id in portraits.keys():
        var portrait = portraits[id]
        var is_active = unit != null and unit.character.id == id
        portrait.set_outline(is_active)
        
        if is_active:
            active_portrait.setup(unit.character)
            

func _on_turn_updated(turn):
    render_portraits(turn.characters_awaiting)         
            

func _on_Turn_pressed():
    _battle.next_turn()

extends CanvasLayer

var Portrait = preload("res://Battle/Interface/Portrait.tscn")

onready var frames = $Layout/Rows/Columns/Characters/Frames
onready var active_portrait = $Layout/Rows/Columns/MarginContainer/ActivePortrait
onready var turn_count = $Layout/Rows/Columns/TurnCount

onready var portraits = {}

var active_character_id:String

var _battle

func _ready():
    _battle = get_parent()
    render_portraits(_battle.current_turn)
    
    SignalManager.connect("character_selected", self, "_on_character_selected")
    SignalManager.connect("portrait_selected", self, "_on_portrait_selected")
    SignalManager.connect("turn_updated", self, "_on_turn_updated")


func render_portraits(turn):
    var character_ids = []
    
    # Render character portraits
    for character in turn.characters_total:
        if turn.character_is_done(character.id):
            # Don't add the character if their turn is complete.
            continue
        
        character_ids.append(character.id)
        if portraits.has(character.id):
            continue
        
        # Create new portrait instance...
        var portrait = Portrait.instance()
        var is_active = active_character_id == character.id
        frames.add_child(portrait)
        portrait.setup(character)
        
        # Save a reference for future selections.
        portraits[character.id] = portrait
    
    # Remove any frames tied to characters that are
    # no longer in the list to be rendered.
    for portrait in frames.get_children():
        if not character_ids.has(portrait.character_id):
            portraits.erase(portrait.character_id)
            portrait.queue_free()


func _on_character_selected(character):
    if character.id == active_character_id:
        return
    
    # Activate the selected portrait by unit
    for id in portraits.keys():
        var portrait = portraits[id]
        var is_active = character.id == id
        portrait.set_outline(is_active)
        
        if is_active:
            active_portrait.setup(character)
            active_character_id = id


func _on_portrait_selected(character_id):
    if character_id == active_character_id:
        return
    
    # Activate the selected portrait by character id.
    for id in portraits.keys():
        var portrait = portraits[id]
        var is_active = character_id == id
        portrait.set_outline(is_active)
        
        if is_active:
            active_character_id = id


func _on_turn_updated(turn):
    render_portraits(turn)
    turn_count.text = "Turn: %s" % turn.turn_count  
            

func _on_Turn_pressed():
    _battle.next_turn()

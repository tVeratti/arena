extends CanvasLayer

var Portrait = preload("res://Battle/Interface/Portrait.tscn")

onready var frames = $Layout/Rows/Columns/Characters/Frames
onready var active_portrait = $Layout/Rows/Columns/MarginContainer/ActivePortrait
onready var turn_count = $Layout/Rows/Columns/BattleInfo/TurnCount
onready var battle_state = $Layout/Rows/Columns/BattleInfo/ActionState

onready var move_button = $Layout/Rows/Actions/Move
onready var attack_button = $Layout/Rows/Actions/Attack
onready var analyze_button = $Layout/Rows/Actions/Analyze

onready var portraits = {}

var _battle

func _ready():
    _battle = get_parent()
    render_portraits(_battle.current_turn)
    
    SignalManager.connect("character_selected", self, "_on_character_selected")
    SignalManager.connect("turn_updated", self, "_on_turn_updated")
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")


func render_portraits(turn):
    var active_character_id = _get_active_character_id()
    var character_ids = []
    
    # Render character portraits
    for character in turn.characters_total:
        if turn.character_done(character.id):
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
        if not character_ids.has(portrait.character.id):
            portraits.erase(portrait)
            portrait.queue_free()
            

func _update_everything():
    var active_character_id = _get_active_character_id()
    
    # Activate the selected portrait by unit
    for id in portraits.keys():
        var portrait = portraits[id]        
        var is_active = active_character_id == id
        portrait.set_outline(is_active)
        
        if is_active:
            active_portrait.setup(_battle.active_character)
            active_character_id = id
    
    
    update_button(move_button, active_character_id, Action.MOVE)
    update_button(attack_button, active_character_id, Action.ATTACK)


func update_button(button, character_id, state):
    var current_turn = _battle.current_turn
    button.disabled = !current_turn.can_take_action(character_id, state)


func _on_character_selected(character):
    _update_everything()
    

func _get_active_character_id():
    var active_character_id = ""
    if _battle.active_character != null:
        active_character_id = _battle.active_character.id
    
    return active_character_id


func _on_turn_updated(turn):
    _update_everything()
    turn_count.text = "Turn: %s" % turn.turn_count
    
    
func _on_battle_state_updated(state):
    battle_state.text = state 
            

func _on_Turn_pressed():
    _battle.next_turn()
    _update_everything()

func _on_Move_pressed():
    _battle.set_action_state(Action.MOVE)


func _on_Attack_pressed():
    _battle.set_action_state(Action.ATTACK)


func _on_Analyze_pressed():
    pass # Replace with function body.

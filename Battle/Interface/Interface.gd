extends CanvasLayer

var Portrait = preload("res://Battle/Interface/Portrait.tscn")

onready var frames = $Layout/Rows/Columns/Characters/Frames
onready var turn_count = $Layout/Rows/Columns/BattleInfo/TurnCount
onready var battle_state = $Layout/Rows/Columns/BattleInfo/ActionState

onready var actions = $Layout/Rows/Actions
onready var turn_button = $Layout/Rows/Actions/Turn
onready var move_button = $Layout/Rows/Actions/Move
onready var attack_button = $Layout/Rows/Actions/Attack
onready var analyze_button = $Layout/Rows/Actions/Analyze

var actions_showing:bool = false

onready var portraits:Array setget , _get_portraits
var active_character:Character

var _battle

func _ready():
    _battle = get_parent()
    
    SignalManager.connect("character_selected", self, "_on_character_selected")
    SignalManager.connect("turn_updated", self, "_on_turn_updated")
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")
    SignalManager.connect("unit_movement_done", self, "_on_unit_movement_done")


func setup():
    var turn = _battle.current_turn
    active_character = _battle.active_character
    
    # Render character portraits
    for character in turn.characters_total:
        # Create new portrait instance...
        var portrait = Portrait.instance()
        frames.add_child(portrait)
        portrait.setup(character)
            

func _update_everything(character = null):
    if character != null:
        active_character = character
    
    var portraits = self.portraits
    for portrait in portraits:   
        # Activate the selected portrait by unit    
        var is_active = active_character != null and active_character.id == portrait.character.id
        portrait.set_outline(is_active)
        
    
    for portrait in portraits:
        # Remove any frames tied to characters that are
        # no longer in the list to be rendered.
        if !portrait.character.is_alive:
            portraits.erase(portrait)
            portrait.queue_free()
    
    # Hide actions during enemy turn.
    if active_character == null or _battle.current_turn.is_enemy:
        if actions_showing:
            actions.hide()
            actions_showing = false
    elif !actions_showing:
        actions.show()
        actions_showing = true
    
    # Disable/enable buttons based on current state and what the character can do.
    update_button(move_button, Action.MOVE)
    update_button(attack_button, Action.ATTACK)
    update_button(analyze_button, Action.ANALYZE)

    turn_button.disabled = _battle.action_state == Action.FREEZE
        

func update_button(button, state):
    var current_turn = _battle.current_turn

    if  active_character == null or \
        active_character.is_enemy or \
        !current_turn.can_take_action(active_character.id, state) or \
        _battle.action_state == Action.FREEZE:
            button.disabled = true
    else:
        button.disabled = false


func _get_portraits():
    return get_tree().get_nodes_in_group("portraits")


func _on_character_selected(character):
    _update_everything(character)


func _on_turn_updated(turn):
    _update_everything(_battle.active_character)
    turn_count.text = "Turn: %s" % turn.turn_count
    
    
func _on_battle_state_updated(state):
    _update_everything()
    battle_state.text = state 


func _on_unit_movement_done():
    _update_everything(_battle.active_character)    


func _on_Turn_pressed():
    _battle.next_turn()
    _update_everything(_battle.active_character)

func _on_Move_pressed():
    _battle.set_action_state(Action.MOVE)


func _on_Attack_pressed():
    _battle.set_action_state(Action.ATTACK)


func _on_Analyze_pressed():
    pass # Replace with function body.

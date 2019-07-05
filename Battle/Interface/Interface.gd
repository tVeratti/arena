extends CanvasLayer

var CharacterInfo = preload("res://Battle/Interface/CharacterInfo.tscn")

onready var frames = $Layout/Rows/Columns/Characters/Frames
onready var turn_count = $Layout/Rows/Columns/BattleInfo/TurnCount
onready var battle_state = $Layout/Rows/Columns/BattleInfo/ActionState

var actions:HBoxContainer
var turn_button:Button
var move_button:Button
var attack_button:Button
var analyze_button:Button

onready var character_info = $Layout/Rows/Columns/MarginContainer/CharacterInfo

var actions_showing:bool = false

onready var portraits:Array setget , _get_portraits
var active_character:Character

var _battle

func _ready():
    _battle = get_parent()
    
    SignalManager.connect("unit_focused", self, "_on_unit_focused")
    SignalManager.connect("turn_updated", self, "_on_turn_updated")
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")
    SignalManager.connect("unit_movement_done", self, "_on_unit_movement_done")
    
    actions = get_node("Layout/Rows/MarginContainer/Actions")
    turn_button = actions.get_node("Turn")
    move_button = actions.get_node("Move")
    attack_button = actions.get_node("Primary/MarginContainer/HBoxContainer/Attack")
    analyze_button = actions.get_node("Primary/MarginContainer/HBoxContainer/Analyze")
    


func setup():
    var turn = _battle.current_turn
    active_character = _battle.active_character
    
    # Render character portraits
    for unit in turn.units_total:
        # Create new portrait instance...
        var portrait = CharacterInfo.instance()
        frames.add_child(portrait)
        portrait.setup(unit, "BASIC")
    
    character_info.setup(null, "FULL")
    
            

func _update_everything(character = null):
    if character != null:
        active_character = character
    
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


func _on_unit_focused(unit):
    if unit != null:
        _update_everything(unit.character)


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
    _battle.set_action_state(Action.ANALYZE)

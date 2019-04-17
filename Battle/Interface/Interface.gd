extends CanvasLayer

var Portrait = preload("res://Battle/Interface/Portrait.tscn")

onready var frames = $Layout/Rows/Columns/Characters/Frames
onready var turn_count = $Layout/Rows/Columns/BattleInfo/TurnCount
onready var battle_state = $Layout/Rows/Columns/BattleInfo/ActionState

onready var move_button = $Layout/Rows/Actions/Move
onready var attack_button = $Layout/Rows/Actions/Attack
onready var analyze_button = $Layout/Rows/Actions/Analyze

onready var portraits:Array setget , _get_portraits
var active_character:Character

var _battle

func _ready():
    _battle = get_parent()
    initialize_portraits(_battle.current_turn)
    
    SignalManager.connect("character_selected", self, "_on_character_selected")
    SignalManager.connect("turn_updated", self, "_on_turn_updated")
    SignalManager.connect("battle_state_updated", self, "_on_battle_state_updated")


func initialize_portraits(turn):
    active_character = _battle.active_character
    
    # Render character portraits
    for character in turn.characters_total:
        # Create new portrait instance...
        var portrait = Portrait.instance()
        frames.add_child(portrait)
        portrait.setup(character)
            

func _update_everything(character):
    active_character = character
    
    var portraits = self.portraits
    for portrait in portraits:   
        # Activate the selected portrait by unit    
        var is_active = active_character != null and active_character.id == portrait.character.id
        portrait.set_outline(is_active)
        
    
    for portrait in portraits:
        # Remove any frames tied to characters that are
        # no longer in the list to be rendered.
        if not _battle.current_turn.characters_total.has(portrait.character):
            portraits.erase(portrait)
            portrait.queue_free()
    
    update_button(move_button, active_character, Action.MOVE)
    update_button(attack_button, active_character, Action.ATTACK)
    update_button(analyze_button, active_character, Action.ANALYZE)


func update_button(button, character, state):
    var current_turn = _battle.current_turn
    button.disabled = !current_turn.can_take_action(character.id, state)
    if character.is_enemy:
        button.hide()
    else:
        button.show()


func _get_portraits():
    return get_tree().get_nodes_in_group("portraits")


func _on_character_selected(character):
    _update_everything(character)


func _on_turn_updated(turn):
    _update_everything(_battle.active_character)
    turn_count.text = "Turn: %s" % turn.turn_count
    
    
func _on_battle_state_updated(state):
    battle_state.text = state 
            

func _on_Turn_pressed():
    _battle.next_turn()
    _update_everything(_battle.active_character)

func _on_Move_pressed():
    _battle.set_action_state(Action.MOVE)


func _on_Attack_pressed():
    _battle.set_action_state(Action.ATTACK)


func _on_Analyze_pressed():
    pass # Replace with function body.

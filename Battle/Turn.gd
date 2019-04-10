extends Object

class_name Turn

var Action = preload("res://Battle/Action.gd")

var actions_taken = {}
var characters_total = []
var characters_done = []
var turn_count:int

func _init(characters, turn_count):
    self.characters_total = characters
    self.turn_count = turn_count
    
    SignalManager.emit_signal("turn_updated", self)


func is_complete() -> bool:
    for character in characters_total:
        # Check if the character has taken any actions.
        if not actions_taken.has(character.id):
            return false
            
        # Check that all actions have been taken by this character.
        if character_is_done(character):
            return false
   
    # All characters have taken all actions.
    return true

func character_is_done(id) -> bool:
    return actions_taken.has(id) and\
        actions_taken[id].has(Action.MOVE)
        # and actions_taken[character.id][Action.ATTACK]:

func take_action(character:Character, action:Action) -> bool:
    var can_take_action = true
    var c_id = character.id
    var a_id = action.type
    
    if actions_taken.has(c_id):
        if actions_taken[c_id].has(a_id):
            # This character has already taken this action.
            # Return false to indicate that the action was not taken.
            can_take_action = false
        else:
            actions_taken[c_id][a_id] = action
    else:
        actions_taken[c_id] = {}
        actions_taken[c_id][a_id] = action
    
    if can_take_action:
        SignalManager.emit_signal("turn_updated", self)
    
    # TODO:
    # update "characters_awaiting" or another array to store the CURRENT list
    
    # Return true to indicate that the action was taken.
    return can_take_action

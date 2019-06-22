extends Object

class_name Turn

var Action = preload("res://Battle/Action.gd")

var actions_taken = {}
var last_actions = {}
var characters_total = []
var turn_count:int

var is_enemy:bool = false
var taunts = []

func _init(characters, turn_count, is_enemy):
    self.characters_total = characters
    self.turn_count = turn_count
    self.is_enemy = is_enemy
    
    for character in characters:
        last_actions[character.id] = Action.WAIT
    
    SignalManager.emit_signal("turn_updated", self)


func next_possible_action(id):
    if can_take_action(id, Action.MOVE):
        return Action.MOVE
    elif can_take_action(id, Action.ATTACK):
        return Action.ATTACK
    else:
        return Action.WAIT


func next_character() -> Character:
    for character in characters_total:
        if !character_done(character.id):
            return character
    
    return null


func last_action(character):
    return last_actions[character.id] 


func is_complete() -> bool:
    for character in characters_total:
        # Check if the character has taken any actions.
        if not actions_taken.has(character.id):
            return false
            
        # Check that all actions have been taken by this character.
        if character_done(character):
            return false
   
    # All characters have taken all actions.
    return true


func can_take_action(id, type) -> bool:
    return type == Action.FREEZE or \
        type == Action.WAIT or \
        not actions_taken.has(id) or \
        not actions_taken[id].has(type)


func character_done(id) -> bool:
    return not can_take_action(id, Action.MOVE) and not can_take_action(id, Action.ATTACK)


func take_action(character:Character, action:String) -> bool:
    var can_take_action = true
    var c_id = character.id
    var a_id = action
    
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
    
    last_actions[c_id] = a_id
    
    # Return true to indicate that the action was taken.
    return can_take_action

func can_be_taunted(id) -> bool:
    if !taunts.has(id):
        taunts.append(id)
        return true
    else: return false
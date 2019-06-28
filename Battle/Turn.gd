extends Object

class_name Turn

var Action = preload("res://Battle/Action.gd")

var actions_taken = {}
var last_actions = {}
var units_total = []
var turn_count:int

var is_enemy:bool = false
var taunts = []

func _init(units, turn_count, is_enemy):
    self.units_total = units
    self.turn_count = turn_count
    self.is_enemy = is_enemy
    
    for unit in units:
        last_actions[unit.character.id] = Action.WAIT
    
    SignalManager.emit_signal("turn_updated", self)


func next_possible_action(id):
    if can_take_action(id, Action.MOVE):
        return Action.MOVE
    elif can_take_action(id, Action.ATTACK):
        return Action.ATTACK
    else:
        return Action.WAIT


func next_character() -> Character:
    for unit in units_total:
        if !character_done(unit.character.id):
            return unit.character
    
    return null


func last_action(character):
    return last_actions[character.id] 


func is_complete() -> bool:
    for unit in units_total:
        # Check if the character has taken any actions.
        if not actions_taken.has(unit.character.id):
            return false
            
        # Check that all actions have been taken by this character.
        if character_done(unit.character):
            return false
   
    # All characters have taken all actions.
    return true


func can_take_action(id, type) -> bool:
    var group = Action.GROUPS[type]
    return group == Action.FREE or \
        not actions_taken.has(id) or \
        not actions_taken[id].has(group)


func character_done(id) -> bool:
    return not can_take_action(id, Action.MOVE) and not can_take_action(id, Action.ATTACK)


func take_action(character:Character, action:String) -> bool:
    var c_id = character.id
    var can_take_action = can_take_action(c_id, action)
    var group = Action.GROUPS[action]
    
    if actions_taken.has(c_id):
        if can_take_action:
            actions_taken[c_id][group] = action
    else:
        actions_taken[c_id] = {}
        actions_taken[c_id][group] = action
    
    if can_take_action:
        SignalManager.emit_signal("turn_updated", self)
    
    last_actions[c_id] = action
    
    # Return true to indicate that the action was taken.
    return can_take_action


func can_be_taunted(id) -> bool:
    if !taunts.has(id):
        taunts.append(id)
        return true
    else: return false
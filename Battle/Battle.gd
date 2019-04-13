extends Node

var Character = preload("res://Character/Character.gd")
var Turn = preload("res://Battle/Turn.gd")
var Action = preload("res://Battle/Action.gd")

var heroes:Array
var enemies:Array

var current_turn:Turn
var current_turn_count:int = 1

var active_character:Character
var action_state:String = Action.WAIT

onready var Grid = $Grid


func setup(heroes, enemies):
    self.heroes = heroes
    self.enemies = enemies
    self.current_turn = Turn.new(heroes, current_turn_count)


func _ready():
    Grid.add_characters(heroes)
    
    SignalManager.connect("character_selected", self, "_on_character_selected")


func activate_character(character):
    if character != active_character:
        active_character = character
        Grid.activate_character(active_character)
        
        var next_possible_action = current_turn.next_possible_action(character.id)
        set_action_state(next_possible_action)


func set_action_state(next_state):
    # Verify that the next state is valid for the current battle state.
    if action_state == next_state or\
    active_character == null or\
    not current_turn.can_take_action(active_character.id, next_state):
        return

    if action_state == Action.MOVE and next_state != Action.MOVE:
        Grid.deactivate()
    
    match(next_state):
        Action.MOVE:
            pass
        Action.ATTACK:
            pass
        Action.WAIT:
            pass
            
    action_state = next_state
    SignalManager.emit_signal("battle_state_updated", action_state)


func next_turn():
    current_turn_count += 1
    current_turn = Turn.new(heroes, current_turn_count)
    activate_character(heroes[0])


func character_move() -> bool:
    var did_move = character_action(Action.MOVE)
    if did_move:
        set_action_state(Action.WAIT)

    return did_move


func character_attack(target:Character, distance):
    # Check that the current character can reach the target.
    print(distance)
    if distance > active_character.attack_range:
        return false
    
    var did_attack = character_action(Action.ATTACK)
    if did_attack:
        # Roll for avoidance based on target's speed.
        var avoidance = rand_range(0, target.speed)
        if avoidance > active_character.speed:
            return false
        
        var damage = active_character.deal_damage()
        var final_damage = target.take_damage(damage)
        print("Damage dealt: %s, %s, %s" % [damage, final_damage, target.health.value_current])
        set_action_state(Action.WAIT)


func character_action(type):
    var action = Action.new(type)
    return current_turn.take_action(active_character, action)
 

func _on_turn_ended():
    next_turn()
    
func _on_character_selected(character):
    activate_character(character)
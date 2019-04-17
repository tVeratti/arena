extends Node

var Character = preload("res://Character/Character.gd")
var Turn = preload("res://Battle/Turn.gd")
var Action = preload("res://Battle/Action.gd")

var SkillCheck = preload("res://Battle/SkillCheck/SkillCheck.tscn")
var CombatText = preload("res://Battle/CombatText.tscn")

var heroes:Array
var enemies:Array

var current_turn:Turn
var current_turn_count:int = 1

var active_unit:Unit
var active_target:Unit
var action_state:String = Action.WAIT
var active_character:Character setget , _get_active_character

onready var Grid = $Grid


func setup(heroes, enemies):
    self.heroes = heroes
    self.enemies = enemies
    self.current_turn = Turn.new(heroes, current_turn_count)


func _ready():
    Grid.add_characters(heroes)
    Grid.add_characters(enemies, true)
    
    SignalManager.connect("character_selected", self, "_on_character_selected")


func activate_character(character):
    if character != self.active_character:
        active_unit = Grid.activate_character(character)
        
        var next_possible_action = current_turn.next_possible_action(character.id)
        set_action_state(next_possible_action)


func set_action_state(next_state):
    # Verify that the next state is valid for the current battle state.
    if action_state == next_state or\
    active_unit == null or\
    not current_turn.can_take_action(self.active_character.id, next_state):
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


func character_move() -> bool:
    var did_move = character_action(Action.MOVE)
    if did_move:
        set_action_state(Action.WAIT)

    return did_move


func character_attack(target:Unit, distance):
    # Check that the current character can reach the target.
    if distance > self.active_character.attack_range:
        return false
    
    var did_attack = character_action(Action.ATTACK)
    if did_attack:
        active_target = target
        
        # Initiate a skill check which will call
        # resolve_attack when the player compeletes it.
        var skill_check = SkillCheck.instance()
        add_child(skill_check)
        skill_check.setup(self, active_unit, target)


func character_action(type):
    var action = Action.new(type)
    return current_turn.take_action(self.active_character, action)


func resolve_attack(multiplier = 1, label = ""):
    Grid.camera.unlock()
    
    if not active_target or not active_unit:
        return
    
    if multiplier == 0:
        var avoid_text = CombatText.instance()
        active_target.add_child(avoid_text)
        avoid_text.setup(label, "")
        set_action_state(Action.WAIT)
        return false
    
    # Calculate final damage after target's mitigation.
    var target = active_target.character
    var damage = self.active_character.deal_damage() * multiplier
    var final_damage = int(target.take_damage(damage))
    
    # Render the damage done...
    var damage_text = CombatText.instance()
    active_target.add_child(damage_text)
    damage_text.setup(final_damage, label)
    
    if !target.is_alive:
        _handle_character_death(target)
        
    SignalManager.emit_signal("health_changed", target)
    
    set_action_state(Action.WAIT)
    active_target = null


func _handle_character_death(character):
    if character.is_enemy:
        enemies.erase(character)
    else:
        heroes.erase(character)
        current_turn.characters_total.erase(character)


func _on_turn_ended():
    next_turn()
    
func _on_character_selected(character):
    activate_character(character)
    
func _get_active_character():
    if active_unit != null and active_unit.character != null:
        return active_unit.character
    

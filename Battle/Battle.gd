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
var previous_turn:Turn

var active_unit:Unit
var active_targets:Array = []
var action_state:String = Action.WAIT
var active_character:Character setget , _get_active_character

var current_telegraph:Telegraph

onready var Grid = $Grid


func setup(battle):
    self.heroes = battle.heroes
    self.enemies = battle.enemies
    self.current_turn = Turn.new(battle.heroes, current_turn_count)
    self.previous_turn = self.current_turn
    
    $Interface.setup()
    Grid.add_characters(heroes)
    Grid.add_characters(enemies, true)


func _ready():
    SignalManager.connect("character_selected", self, "_on_character_selected")
    SignalManager.connect("telegraph_executed", self, "_on_telegraph_executed")


func activate_character(character:Character):
    active_unit = Grid.activate_character(character)
    
    # Allow auto-selection of next action... maybe a setting later.
    # var next_action = current_turn.next_possible_action(character.id)
    # set_action_state(next_action)


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
            Grid.show_telegraph(self.active_character.attack_range)
        Action.WAIT:
            pass
            
    action_state = next_state
    SignalManager.emit_signal("battle_state_updated", action_state)


func next_turn():
    previous_turn = current_turn
    current_turn_count += 1
    current_turn = Turn.new(heroes, current_turn_count)
    
    activate_character(self.active_character)


func character_move() -> bool:
    var did_move = character_action(Action.MOVE)
    if did_move:
        set_action_state(Action.WAIT)

    return did_move


func character_attack(targets:Array):
    if targets.size() == 0:
        set_action_state(Action.WAIT)
        return
      
    var did_attack = character_action(Action.ATTACK)
    if did_attack:    
        active_targets = targets
        
        var target_speed = 0
        for target in targets:
            target_speed += target.character.speed
        target_speed /= targets.size()
        
        # Initiate a skill check which will call
        # resolve_attack when the player compeletes it.
        var skill_check = SkillCheck.instance()
        add_child(skill_check)
        skill_check.setup(self, active_unit, target_speed)


func character_action(type):
    var action = Action.new(type)
    return current_turn.take_action(self.active_character, action)


func resolve_attack(multiplier = 1, label = ""):
    
    if not active_targets or active_targets.size() == 0 or not active_unit:
        return
    
    if multiplier == 0:
        #var avoid_text = CombatText.instance()
        #active_target.add_child(avoid_text)
        #avoid_text.setup(label, "")
        #set_action_state(Action.WAIT)
        return false
        
    # Reduce damage by how many targets are being hit (spread)
    var aoe_multiplier:float = float(active_targets.size()) / 2
    print(aoe_multiplier)
    
    # Calculate final damage after target's mitigation.
    for target in active_targets:
        var target_character = target.character
        var damage = (self.active_character.deal_damage() * multiplier) / aoe_multiplier
        var final_damage = int(target_character.take_damage(damage))
        
        # Render the damage done...
        var damage_text = CombatText.instance()
        target.add_child(damage_text)
        damage_text.setup(final_damage, label)
        
        if !target_character.is_alive:
            _handle_character_death(target_character)
            
        SignalManager.emit_signal("health_changed", target_character)
    
    set_action_state(Action.WAIT)
    active_targets = []


func _handle_character_death(target):
    var full_list = enemies
    if !target.is_enemy:
        full_list = heroes
        current_turn.characters_total.erase(target)
    
    var all_dead = true
    for character in full_list:
        if character.is_alive:
            all_dead = false
            break
    
    if all_dead:
        # END THE BATTLE, one side is 100% dead
        ScreenManager.change_to(Scenes.BATTLE_EXIT, {
            "heroes": heroes,
            "enemies": enemies,
            "winner": "player" if target.is_enemy else "enemy"
        })


func _on_telegraph_executed(bodies):
    var targets = []
    for body in bodies:
        var unit = body as Unit
        if unit.character.id != self.active_character.id:
            targets.append(unit)
        
    character_attack(targets)


func _on_turn_ended():
    next_turn()


func _on_character_selected(character):
    activate_character(character)


func _get_active_character():
    if active_unit != null and active_unit.character != null:
        return active_unit.character
    

extends Node

var Character = load("res://Character/Character.gd")
var Turn = load("res://Battle/Turn.gd")
var Action = load("res://Battle/Action.gd")

var SkillCheck = preload("res://Battle/SkillCheck/SkillCheck.tscn")
var CombatText = preload("res://Battle/CombatText.tscn")

var heroes:Array
var enemies:Array

var current_turn
var current_turn_count:int = 1
var end_turn_confirmation:bool = false

var active_unit:Unit
var active_character:Character setget , _get_active_character

var active_targets:Array = []
var action_state:String = Action.WAIT
var action_debounce:bool = false

onready var Grid = $Grid
onready var ActionTimer = $ActionTimer
onready var AttackTimer = $AttackTimer
onready var EndTurnDialog = $Interface/EndTurnDialog


func setup(battle):
    self.heroes = battle.heroes
    self.enemies = battle.enemies
    self.current_turn = Turn.new(battle.heroes, current_turn_count, false)
    
    $Interface.setup()
    Grid.add_characters(heroes)
    Grid.add_characters(enemies, true)


func _ready():
    SignalManager.connect("character_selected", self, "_on_character_selected")
    SignalManager.connect("unit_targeted", self, "_on_unit_targeted")
    SignalManager.connect("unit_movement_done", self, "_on_movement_done")


func _input(event):
    if action_state != Action.FREEZE:
        if Input.is_action_pressed("cheat"):
            heroes[0].agility = 10
        if Input.is_action_pressed("actions_attack"):
            set_action_state(Action.ATTACK)
        elif Input.is_action_pressed("actions_move"):
            set_action_state(Action.MOVE)
        elif Input.is_action_pressed("actions_cancel"):
            set_action_state(Action.WAIT)
        elif Input.is_action_pressed("actions_turn"):
            next_turn()
        elif Input.is_action_just_released("next") or Input.is_action_just_released("previous"):
            action_debounce = false
        else:
            var is_next = Input.is_action_pressed("next")
            var is_prev = Input.is_action_pressed("previous")
            if is_next or is_prev:
                if action_debounce: return
                debounce_actions()
            
                var living_characters = get_living_characters(heroes)
                var character_index = living_characters.find(self.active_character)
                var max_index = living_characters.size() - 1
                
                if !is_prev:
                    if character_index < max_index:
                        character_index += 1
                    else:
                        character_index = 0
                else:
                    if character_index > 0:
                        character_index -= 1
                    else:
                        character_index = max_index
                
                set_action_state(Action.WAIT)
                activate_character(living_characters[character_index])


func _notification(event):
    if event == MainLoop.NOTIFICATION_WM_FOCUS_OUT and \
        action_state != Action.FREEZE:
            set_action_state(Action.WAIT)


# TURN ACTIVATION
# -----------------------------

# Activate enemies and let the next possible one take an action,
# until none can and the next turns (player) begins
func activate_enemies():
    var active_enemy = current_turn.next_character()
    if active_enemy == null:
        set_action_state(Action.WAIT)
        return next_turn()
        
    set_action_state(Action.FREEZE)
    
    active_unit = Grid.activate_character(active_enemy)
    
    # Get the next action and update the turn.
    var next_action = current_turn.next_possible_action(active_enemy.id)
    current_turn.take_action(active_enemy, next_action)
    
    # Let the AI decide to do with the current action...
    if next_action == Action.MOVE:
        # This starts movement which won't activated
        # enemies again until it finishes.
        if Grid.move_to_nearest_unit(active_unit):
            return
        
    elif next_action == Action.ATTACK:
        var nearest_unit = Grid.get_nearest_unit(active_unit)
        if is_instance_valid(nearest_unit) and is_instance_valid(active_unit) and \
            nearest_unit.position.distance_to(active_unit.position) <= active_enemy.attack_range * Grid.map.cell_size.x:
                active_targets = [nearest_unit]
                resolve_attack(1, "")
      
    activate_enemies()


# When a character is selected, activate it on the grid
# and apply any other changes necessary.
func activate_character(character:Character):
    active_unit = Grid.activate_character(character)
    
    # Allow auto-selection of next action... maybe a setting later.
    # var next_action = current_turn.next_possible_action(character.id)
    # set_action_state(next_action)
    

# End the current turn, and activate the next group.
func next_turn():    
    if current_turn.is_enemy:
        current_turn_count += 1
        var characters = get_living_characters(heroes)
        current_turn = Turn.new(characters, current_turn_count, false)
        end_turn_confirmation = false
        
        # If any characters are alive, activate now.
        if characters.size() > 0:
            activate_character(characters[0])
    else:
        # If there are still remaining actions, ask the player
        # to confirm the end of the turn before continuing.
        if !current_turn.is_complete() and !end_turn_confirmation:
            EndTurnDialog.popup_centered(Vector2.ZERO)
            return
        
        var characters = get_living_characters(enemies)
        current_turn = Turn.new(characters, current_turn_count, true)
        activate_enemies()


func get_living_characters(all):
    var living = []
    for character in all:
        if character.is_alive:
            living.append(character)
    
    return living


# CHARACTER ACTIONS
# -----------------------------

# Check if the character can move, then return if
# the action has been logged in the turn.
func character_move() -> bool:
    var did_move = character_action(Action.MOVE)
    if did_move:
        set_action_state(Action.FREEZE)

    return did_move


# Telgegraph has completed and the targets are chosen,
# so continue with the skillcheck.
func character_attack(targets:Array):
    if targets.size() == 0:
        AttackTimer.start(0.3)
        return
 
    var did_attack = character_action(Action.ATTACK)
    if did_attack:    
        active_targets = targets
        
        # Get average target speed.
        var target_speed = 0
        for target in targets:
            target_speed += target.character.speed
        target_speed /= targets.size()
        
        # Initiate a skill check which will call
        # resolve_attack when the player compeletes it.
        var skill_check = SkillCheck.instance()
        add_child(skill_check)
        skill_check.setup(self, active_unit, target_speed)
        set_action_state(Action.FREEZE)
        Grid.deactivate()


func character_action(type):
    if action_state == Action.FREEZE:
        return false
    
    return current_turn.take_action(self.active_character, type)


# Change the action state of the battle and handle some
# transitional logic between states.
func set_action_state(next_state):    
    # Verify that the next state is valid for the current battle state.
    if action_state == next_state or\
        not is_instance_valid(active_unit) or\
        not current_turn.can_take_action(self.active_character.id, next_state):
        return

    # The only action state that can follow FREEZE is WAIT.
    # This makes sure that different states are locked during FREEZE.
    if action_state == Action.FREEZE and next_state != Action.WAIT:
        return

    if action_state == Action.MOVE and next_state != Action.MOVE:
        Grid.deactivate()

    match(next_state):
        Action.MOVE:
            if self.active_character.is_enemy: return
            Grid.show_movement_overlay()
        Action.ATTACK:
            if self.active_character.is_enemy: return
            Grid.show_attack_overlay()
        Action.WAIT:
            pass
        Action.FREEZE:
            pass
            
    action_state = next_state
    SignalManager.emit_signal("battle_state_updated", action_state)


func debounce_actions():
    ActionTimer.start(0.5)
    action_debounce = true


# ATTACK RESOLUTION
# -----------------------------

# Skill check completed, calculate damage(s)
func resolve_attack(multiplier = 1, label = ""):
    
    if not active_targets or not active_unit:
        return
        
    # Reduce damage by how many targets are being hit (spread)
    var aoe_multiplier:float = float(active_targets.size()) / 2
    
    # Calculate final damage after target's mitigation.
    for target in active_targets:
        var target_character = target.character
        var damage = (self.active_character.deal_damage() * multiplier) / aoe_multiplier
        var final_damage = int(target_character.take_damage(damage))
        
        target.show_damage(final_damage, label)
        
        if !target_character.is_alive:
            _handle_character_death(target_character)
            
        SignalManager.emit_signal("health_changed", target_character)
        
        if !current_turn.is_enemy:
            AttackTimer.start(0.3)
        
    active_targets = []


# When a character dies, remove them fom the turns list
# and check for a victory/defeat condition of one team
# being entirely deceased.
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


# Player has targeted an enemy in attack phase.
func _on_unit_targeted(unit):
    var attack_range = self.active_character.attack_range
    var distance = unit.coord - active_unit.coord
    if abs(distance.x) <= attack_range and abs(distance.y) <= attack_range:
        character_attack([unit])


# GETTERS
# -----------------------------

func _get_active_character():
    if is_instance_valid(active_unit) and active_unit.character != null:
        return active_unit.character


# SIGNAL LISTENERS
# -----------------------------

func _on_turn_ended():
    next_turn()


func _on_ai_action_taken():
    activate_enemies()


func _on_character_selected(character):    
    activate_character(character)


func _on_movement_done():
    if current_turn.is_enemy:
        activate_enemies()
    else:
        set_action_state(Action.WAIT)


func _on_ActionTimer_timeout():
    action_debounce = false


func _on_EndTurnDialog_confirmed():
    end_turn_confirmation = true
    next_turn()


func _on_AttackTimer_timeout():
    set_action_state(Action.WAIT)

extends Node

var Character = preload("res://Character/Character.gd")
var Turn = preload("res://Battle/Turn.gd")
var Action = preload("res://Battle/Action.gd")


var heroes:Array
var enemies:Array


var current_turn:Turn
var current_turn_count:int = 1


func setup(heroes, enemies):
    self.heroes = heroes
    self.enemies = enemies
    self.current_turn = Turn.new(heroes, current_turn_count)


func _ready():
    $Grid.add_characters(heroes)
    

func next_turn():
    current_turn_count += 1
    current_turn = Turn.new(heroes, current_turn_count)


func character_move(character) -> bool:
    return character_action(character, Action.MOVE)


func character_attack(character) -> bool:
    return character_action(character, Action.ATTACK)


func character_action(character, type):
    var action = Action.new(type)
    return current_turn.take_action(character, action)
 

func _on_turn_ended():
    next_turn()
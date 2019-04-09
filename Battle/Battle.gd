extends Node

var Character = preload("res://Character/Character.gd")

var heroes:Array
var enemies:Array

var activeCharacter

func setup(heroes, enemies):
    self.heroes = heroes
    self.enemies = enemies
    
func _ready():
    $Grid.add_characters(heroes)
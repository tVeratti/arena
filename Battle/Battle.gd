extends Node

var heroes:Array
var enemies:Array

func setup(heroes, enemies):
    self.heroes = heroes
    self.enemies = enemies
    
func _ready():
    $Grid.add_characters(heroes)
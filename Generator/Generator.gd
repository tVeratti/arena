extends Node2D

var PARTS = preload("res://Generator/Part.gd").PARTS

onready var source = $Rig
onready var info = $CharacterInfo

onready var acuity = $Stats/Acuity
onready var constitution = $Stats/Constitution
onready var agility = $Stats/Agility

var character:Character

func _ready():
    character = Character.new("New Character")
    generate()


func generate():
    character.generate()
    source.set_textures(character.textures)
    source.set_colors(character.colors)
    info.set_character(character)
    
    acuity.set_stat(character.acuity_stat, character)
    constitution.set_stat(character.constitution_stat, character)
    agility.set_stat(character.agility_stat, character)


func _on_Randomize_pressed():
    randomize()
    generate()


func _on_Back_pressed():
    source.set_facing("BACK")


func _on_Front_pressed():
    source.set_facing("FRONT")

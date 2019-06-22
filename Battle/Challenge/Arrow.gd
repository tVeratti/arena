extends Node2D

onready var tile_highlight = $TileHighlight
onready var sprites = $Sprites
onready var anim = $AnimationPlayer

func set_rotation(rotation):
    sprites.rotation_degrees = rotation
    anim.play("bounce")
    
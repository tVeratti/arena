extends Node2D

# mjyiuykymhmkydkjyiky

var Pathfinder = preload("res://Grid/AStarPathfinder.gd")
var _pathfinder

enum { TILE_NONE = -1, TILE_GRASS = 0 }

var _tile_map:Array = []

var _tile_focused
var _tile_selected

# Cache nodes
onready var Map = $TileMap
onready var Cam = $Camera
onready var Selection = $Selection

var Character = preload("res://Character/Character.tscn")
var character_positions = {}
var character_selected

func _ready():
    # Initialize A* Pathfinder with the TileMap
    _pathfinder = Pathfinder.new(Map, _tile_map)


func add_characters(characters):
    var walkable_tiles = _pathfinder.walkable_tiles()
    
    for i in range(len(characters)):
        var coords = walkable_tiles[i]
        var character = Character.instance()
        character.data = characters[i]
        character.position = Map.map_to_world(coords)
        add_child(character)
        
        # Save the character instance for future reference
        character_positions[coords] = character


func _input(event):
    if event is InputEventMouse:
        var mouse_position = get_global_mouse_position()
        var tile = Map.world_to_map(mouse_position)
        
        if event is InputEventMouseButton:
            # Mouse CLICK - Tile selection
            if event.button_index == BUTTON_LEFT and event.is_pressed():
                select_tile(tile)
        elif event is InputEventMouseMotion:
            # Mouse OVER - Tile focus
            focus_tile(tile)


func focus_tile(tile):
    if _tile_focused == tile or character_selected == null:
        return
    
    var tile_position = Map.map_to_world(tile)
    var path = _pathfinder.find_path(character_selected.position, tile_position)
    SignalManager.emit_signal("tile_focused", tile, path)
    
    _tile_focused = tile

 
func select_tile(tile):
    _tile_selected = tile
    
    var tile_position = Map.map_to_world(tile)
    Cam.set_target(tile_position)
    Selection.position = tile_position
    
    # Attempt to select a character if there is one on this tile.
    if character_positions.has(tile):
        character_selected = character_positions[tile]
    
    # If a character is already selected, fo pathfinding for that character.
    elif character_selected != null:
        # Navigation
        var new_path = _pathfinder.find_path(character_selected.position, tile_position)
        character_selected.path = new_path
        
        # Update positions tracking for characters
        var old_tile = Map.world_to_map(character_selected.position)
        character_positions[tile] = character_selected
        character_positions[old_tile] = null
        
    SignalManager.emit_signal("tile_selected", tile, character_selected)

    
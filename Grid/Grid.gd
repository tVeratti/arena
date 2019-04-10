extends Node2D

# mjyiuykymhmkydkjyiky

var _pathfinder:AStarPathfinder

# Reference to the parent battle for checking if units
# can take actions or not.
var _battle


# Tiles
enum { TILE_NONE = -1, TILE_GRASS = 0 }
var _tile_focused
var _tile_selected


# Cache child nodes
onready var Map = $TileMap
onready var Cam = $Camera
onready var Selection = $Selection


# Character Units
var Unit = preload("res://Grid/Unit/Unit.tscn")
var unit_selected
var units = []

func _ready():
    _battle = get_parent()
    
    # Initialize A* Pathfinder with the TileMap
    _pathfinder = AStarPathfinder.new(Map)


func add_characters(characters:Array):
    var walkable_tiles = _pathfinder.walkable_tiles()
    
    for i in range(characters.size()):
        var coords:Vector2 = walkable_tiles[i]
        var character:Character = characters[i]
        
        var unit = Unit.instance()
        unit.character = character
        unit.position = Map.map_to_world(coords)
        add_child(unit)
        units.append(unit)


func _unhandled_input(event):
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
    if _tile_focused == tile or unit_selected == null:
        return
    
    var tile_position = Map.map_to_world(tile)
    var path = _pathfinder.find_path(unit_selected.position, tile_position)
    SignalManager.emit_signal("tile_focused", tile, path)
    
    _tile_focused = tile

 
func select_tile(tile):
    _tile_selected = tile
    
    var tile_position = Map.map_to_world(tile)
    Cam.set_target(tile_position)
    Selection.position = tile_position
    
    # Check if there is a unit occupying this tile...
    var unit_on_tile
    for unit in units:
        if tile == Map.world_to_map(unit.position):
            unit_on_tile = unit
            break        
    
    if unit_on_tile != null:
        # Select the unit and do not start pathfinding.
        unit_selected = unit_on_tile
    elif unit_selected != null:
        # If a unit is already selected, do pathfinding for that unit.
        if _battle.character_move(unit_selected.character):
            var new_path = _pathfinder.find_path(\
            unit_selected.position,\
            tile_position,\
            unit_selected.character.speed)
            unit_selected.path = new_path

        
    SignalManager.emit_signal("tile_selected", tile, unit_selected)

    
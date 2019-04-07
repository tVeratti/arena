extends Node2D

# mjyiuykymhmkydkjyiky

var Pathfinder = preload("res://Grid/AStarPathfinder.gd")
var _pathfinder

enum { TILE_GRASS, TILE_WATER, TILE_NONE = -1 }

export(Vector2) var grid_size:Vector2 = Vector2(10, 10) # rows/columns
var _tile_offset:float

var _tile_map:Array = []

var _tile_focused
var _tile_selected
const _first_tile = Vector2(0, 0)

# Cache nodes
onready var Map = $TileMap
onready var Cam = $Camera
onready var Selection = $Selection
onready var Character = $Character

func _ready():
    Character.position = Map.map_to_world(Vector2(2,2))
    
    # Initialize A* Pathfinder with the TileMap
    _pathfinder = Pathfinder.new(Map, _tile_map)

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

func _draw():
    if _tile_focused != null:
        var tile_position = Map.map_to_world(_tile_focused)
        var path = _pathfinder.find_path(Character.position, tile_position)
        
        if path.size() == 0:
            return
            
            
        
        
        

func focus_tile(tile):
    if _tile_focused == tile:
        return
    
    var tile_position = Map.map_to_world(tile)
    var path = _pathfinder.find_path(Character.position, tile_position)
    SignalManager.emit_signal("tile_focused", tile, path)
    
    _tile_focused = tile

 
func select_tile(tile):
    _tile_selected = tile
    
    # Navigation
    var tile_position = Map.map_to_world(tile)
    var new_path = _pathfinder.find_path(Character.position, tile_position)
    Character.path = new_path
    
    if new_path.size() > 0:
        var last_point = new_path[new_path.size() - 1]
        Cam.set_target(last_point)
        Selection.position = last_point
    
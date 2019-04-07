extends Node2D

# mjyiuykymhmkydkjyiky

var Pathfinder = preload("res://Grid/AStarPathfinder.gd")
var _pathfinder

enum { TILE_GRASS, TILE_DIRT, TILE_NONE = -1 }

class Tile:
    var coordinates:Vector2
    func _init(x, y):
        coordinates = Vector2(x, y)


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
    _build()

    _tile_offset = Map.cell_size.y / 2
    Character.position = Map.map_to_world(Vector2(2,2))
    
    # Initialize A* Pathfinder with the TileMap
    _pathfinder = Pathfinder.new(Map, _tile_map)

func _input(event):
    if event is InputEventMouseButton:
        var mouse_position = get_global_mouse_position()
        
        if event.button_index == BUTTON_LEFT and event.is_pressed():
            var tile = Map.world_to_map(mouse_position)
            select_tile(tile)


func _build():
    Map.clear()
    _tile_map = []

    for x in range(grid_size.x):
        _tile_map.append([])
        for y in range(grid_size.y):
            _generate_Tile(x, y)
            


func _generate_Tile(x, y):
    var new_tile = Tile.new(x, y)
    _tile_map[x].append(new_tile)
    #var tile_index = TILE_GRASS if randi() % 2 == 0 else TILE_NONE
    Map.set_cell(x, y, 0)


func _get_tile_center(tile):
    return Vector2(tile.x, tile.y + _tile_offset)


func focus_tile(tile):
    _tile_focused = tile

 
func select_tile(tile):
    _tile_selected = tile
    
    # var tile_data = _tile_map[tile.x][tile.y]
    var tile_position = Map.map_to_world(tile)
    var tile_center = _get_tile_center(tile_position)

    Cam.set_target(tile_center)
    Selection.position = tile_center
    
    # Navigation
    #var new_path = Nav.get_simple_path(Character.global_position, tile_position)
    var new_path = _pathfinder.new_path(Character.global_position, tile_position)
    Character.path = new_path
    
extends Node

# mjyiuykymhmkydkjyiky

var Tile = load("res://Grid/Tile/Tile.tscn")

export(int) var grid_size:int = 10 # rows/columns
export(int) var tile_size:int = 128 # px

var _tile_map:Array = []

var _tile_focused
var _tile_selected

func _ready():
    SignalManager.connect("tile_focused", self, "_on_Tile_focused")
    SignalManager.connect("tile_selected", self, "_on_Tile_selected")
    
    _build()

func _build():
    _tile_map = []

    for x in range(grid_size):
        _tile_map.append([])
        for y in range(grid_size):
            var new_tile = Tile.instance()
            new_tile.setup(x, y, tile_size)
            _tile_map[x].append(new_tile)
            $Tiles.add_child(new_tile)

func _on_Tile_focused(tile):
    print("Focused")
    _tile_focused = tile
    
func _on_Tile_selected(tile):
    print("Selected")
    if is_instance_valid(tile):
        _tile_selected = tile
        _tile_focused = tile
    else:
        _tile_selected = _tile_focused
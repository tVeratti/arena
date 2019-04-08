extends Node2D

const BASE_LINE_WIDTH = 2.0
const DRAW_COLOR = Color('#fff')

const TEXTURE_HIGHLIGHT = preload("res://Grid/Tile/textures/higlight.png")

var _path:Array


func _ready():
    SignalManager.connect("tile_focused", self, "_on_tile_focused")

func _draw():
    if _path.empty():
        return
    
    var point_start = _path[0]
    var point_prev = point_start
    for point in _path:
        draw_line(point_prev, point, DRAW_COLOR, BASE_LINE_WIDTH, true)
        point_prev = point
        
func _on_tile_focused(tile, path):
    if _path == path:
        return
    
    _path = path
    update()
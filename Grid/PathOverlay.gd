extends Node2D

const BASE_LINE_WIDTH = 5.0
const DRAW_COLOR = Color(1,1,1,0.5)

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


func _on_tile_focused(path):
    if _path == path:
        return
    
    _path = path
    update()
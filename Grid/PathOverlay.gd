extends Node2D

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color(1,1,1,1)

var _path:Array


func _ready():
    SignalManager.connect("tile_focused", self, "_on_tile_focused")


func _draw():
    if _path.empty():
        return
    
    var point_start = _path[0]
    var point_end = _path[_path.size() -1]
    var point_prev = point_start
    for point in _path:
        draw_line(point_prev, point, DRAW_COLOR, BASE_LINE_WIDTH, true)
        point_prev = point
    
    draw_circle(point_end, 16, DRAW_COLOR)


func _on_tile_focused(path):
    if _path == path:
        return
    
    _path = path
    update()
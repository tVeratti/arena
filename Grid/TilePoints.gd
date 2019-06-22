extends Node

class_name TilePoints

static func get_tile_points(map):
    var x = map.cell_size.x / 2
    var y = map.cell_size.y / 2
    
    return [
        Vector2(0, y),
        Vector2(-x, 0),
        Vector2(0, y),
        Vector2(x, 0)
    ]
extends Node

var astar_node:AStar
export(Vector2) var map_size = Vector2(16, 16)

var _point_path = []
var _half_cell_size = Vector2(0, 25)

var _tiles:Array
var _map:TileMap

func _init(map:TileMap, tiles:Array):
    astar_node = AStar.new()
    
    _map = map
    _tiles = tiles
    
    set_walkable_cells()
    connect_walkable_cells()  


func set_walkable_cells():
    for row in _tiles:
        for tile in row:
            var point_index = calculate_point_index(tile.coordinates)
            astar_node.add_point(\
            point_index,\
            Vector3(tile.coordinates.x, tile.coordinates.y, 0.0))


func connect_walkable_cells():
    var points_array = []
    for row in _tiles:
        for tile in row:
            var coord = tile.coordinates
            var point_index = calculate_point_index(coord)
            var points_relative = PoolVector2Array([
                Vector2(coord.x + 1, coord.y),
                Vector2(coord.x - 1, coord.y),
                Vector2(coord.x, coord.y + 1),
                Vector2(coord.x, coord.y - 1)])
            for point in points_relative:
                var point_relative_index = calculate_point_index(point)
                astar_node.connect_points(point_index, point_relative_index, false)


func new_path(world_start, world_end):
    var path_start_position = _map.world_to_map(world_start)
    var path_end_position = _map.world_to_map(world_end)
    
    var point_path = calculate_path(path_start_position, path_end_position)
    var path_world = []
    for point in point_path:
        var point_world = _map.map_to_world(Vector2(point.x, point.y)) + _half_cell_size
        path_world.append(point_world)
    
    return path_world

    
func calculate_path(start, end):
    var start_point_index = calculate_point_index(start)
    var end_point_index = calculate_point_index(end)

    return astar_node.get_point_path(start_point_index, end_point_index)


func calculate_point_index(point):
    return point.x + map_size.x * point.y

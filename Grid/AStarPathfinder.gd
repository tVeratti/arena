extends Node

# ASTAR References:
# https://github.com/GDquest/Godot-engine-tutorial-demos/blob/master/2018/03-30-astar-pathfinding/pathfind_astar.gd
# https://medium.com/kitschdigital/2d-path-finding-with-astar-in-godot-3-0-7810a355905a

class_name AStarPathfinder

var _astar:AStar

var _map:TileMap
var _half_cell_size:Vector2

var _walkable_bounds:Rect2
var _walkable_tiles:Array

var _obstacles:Array
var _distance_map:Dictionary = {}


func _init(map:TileMap):
    _astar = AStar.new()
    _map = map
    _half_cell_size = Vector2(0, map.cell_size.y / 2)


func walkable_tiles():
    if _walkable_tiles.size() == 0:
        _walkable_bounds = _map.get_used_rect()
        _walkable_tiles = _map.get_used_cells_by_id(0)
    
    return _walkable_tiles


# If the map hasn't been loaded in for pathfinding,
# (OR if obstacle positions have changed...)
# get all tiles and create astar nodes & connections.
func _get_map_data(new_obstacles):
    if _astar.get_points().empty() or new_obstacles != _obstacles:
        _obstacles = new_obstacles
        _astar.clear()
        # Generate astar points & connections.
        walkable_tiles()
        _set_astar_points()
        _connect_astar_points()
            

# Loop through walkable tiles and create astar points for each.
func _set_astar_points():
    for tile in _walkable_tiles:
        if not _obstacles.has(tile):
            var index = _get_point_index(tile)
            _astar.add_point(index, Vector3(tile.x, tile.y, 0))


# Loop through walkable tiles and create connections to 
# all adjacent tiles (including diagonal).
func _connect_astar_points():
    # var previous_normal = Vector2(0, 0)
    for tile in _walkable_tiles:
        var index = _get_point_index(tile)
        if not _astar.has_point(index):
            continue
        
        # Make a connection quad directions:
        # (-1, -1)     (-1, 0)     (-1, 1)
        # (0, -1)      (0, 0)      (0, 1)
        # (1, -1)      (1, 0)      (1, 1)
        var adjacent_tiles = [
            Vector2.UP,
            Vector2.LEFT,
            Vector2.RIGHT,
            Vector2.DOWN
        ]
        
        for offset in adjacent_tiles:
            var adjacent_tile = tile + offset
            var adjacent_index = _get_point_index(adjacent_tile)
            
            if tile == adjacent_tile or \
            not _astar.has_point(adjacent_index):
                continue
            
            _astar.connect_points(index, adjacent_index, true)
            
            # Try to prefer straight movement
            # DISABLED BECAUSE SLOW
            # var normal = (tile - adjacent_tile).normalized()
            # var weight = 0.9 if normal == previous_normal else 1
            # _astar.set_point_weight_scale(adjacent_index, weight
            # previous_normal = normal


# Take two world-based vectors and find a path between them.
# Returns an array of centered Vector2 positions.
func find_path(world_start, world_end, max_distance = -1, obstacles = []):
    _get_map_data(obstacles)
    
    var point_path = calculate_path(world_start, world_end)
    
    var path_world = []
    for i in range(point_path.size()):
        if max_distance == -1 or i <= max_distance:
            var point = point_path[i]
            var point_world = _map.map_to_world(Vector2(point.x, point.y)) + _half_cell_size
            path_world.append(point_world)
    
    return path_world


# Convert world vectors to unique indexes connected by astar.
# Get a path from astar using start/end indexes.
func calculate_path(world_start, world_end):    
    var start = _map.world_to_map(world_start)
    var end = _map.world_to_map(world_end)
    
    var start_index = _get_point_index(start)
    var end_index = _get_point_index(end)
    
    if not _astar.has_point(start_index) or not _astar.has_point(end_index):
        return []

    return _astar.get_point_path(start_index, end_index)


func _convert_points_to_world(points):
    var points_world = []
    for i in range(points.size()):
        var point = points[i]
        var point_world = _map.map_to_world(Vector2(point.x, point.y)) + _half_cell_size
        points_world.append(point_world)
    
    return points_world


# Convert a coordinate position to a unique point index.
# Astar tracks all points by their unique point index.
func _get_point_index(point):
    var x = point.x - _walkable_bounds.position.x
    var y = point.y - _walkable_bounds.position.y

    return x + y * _walkable_bounds.size.x

func _make_distance_map():
    pass


func get_distance(origin, target) -> int:
    var origin_index = _get_point_index(origin)
    var target_index = _get_point_index(target)
    
    #if not _astar.has_point(origin_index) or not _astar.has_point(target_index):
        #return 1000
        
    return _astar.get_point_path(origin_index, target_index).size()


func has_point(coord):
    var index = _get_point_index(coord)
    return _astar.has_point(index)


func get_adjacent_tiles(origin):
    var point = _map.world_to_map(origin)
    var index = _get_point_index(point)
    var points = _astar.get_point_connections(index)
    return _convert_points_to_world(points)

extends Node2D

const PADDING = 10
const MOVE_COLOR = Color.white
const ATTACK_COLOR = Color.red
var _alpha:float = 0.15

var _mouse:Vector2
var _movement_points:Array
var _attack_points:Array
var _movement_range:int = 1
var _attack_range:int = 1
var _origin:Vector2
var _origin_coord:Vector2
var _exclusions:Array

var _map:TileMap
var _pathfinder:AStarPathfinder
var _x:float
var _y:float


func setup(map:TileMap, pathfinder:AStarPathfinder):
    _map = map
    _pathfinder = pathfinder
    _x = map.cell_size.x / 2
    _y = map.cell_size.y / 2
    

func activate(unit:Unit, exclusions:Array = []):
    _movement_range = unit.character.speed
    _attack_range = unit.character.attack_range
    _origin = unit.position
    _origin_coord = _map.world_to_map(_origin)
    
    _exclusions = exclusions
    
    _get_range_points()


func _input(event):
    pass
    #if event is InputEventMouseButton:
        #_mouse = get_local_mouse_position()
        #_get_range_points()
        
    #elif event is InputEventMouseButton:
        #if event.button_index == BUTTON_LEFT:
            #commit_telegraph()
        #elif event.button_index == BUTTON_RIGHT:
            #cancel_telegraph()
            
    #elif Input.is_action_pressed("actions_accept"):
        #commit_telegraph()


func commit_telegraph():
    SignalManager.emit_signal("telegraph_executed", [])
    queue_free()


func cancel_telegraph():
    SignalManager.emit_signal("telegraph_executed", [])
    queue_free()


func _draw():
    var first = true
    for shape in _movement_points:
        draw_polygon(shape, PoolColorArray([MOVE_COLOR]))
    
    for shape in _attack_points:
        draw_polygon(shape, PoolColorArray([ATTACK_COLOR]))

        #for point in shape:
            #draw_circle(point, 10, Color.white if first else COLOR)
            #first = false

        #var point_start = shape[0]
        #var point_prev = point_start
        #for point in shape:
            #draw_line(point_prev, point, COLOR, 5, true)
            #point_prev = point


func _get_range_points():
    _movement_points = []
    _attack_points = []
    
    var adjacent_tiles = [
        Vector2.LEFT,
        Vector2.LEFT + Vector2.UP,
        Vector2.UP,
        Vector2.UP + Vector2.RIGHT,
        Vector2.RIGHT,
        Vector2.RIGHT + Vector2.DOWN,
        Vector2.DOWN,
        Vector2.DOWN + Vector2.LEFT
    ]
    
    var max_range = _movement_range if _movement_range % 2 != 0 else _movement_range + 1
    for x in range(max_range * 2):
        for y in range(max_range * 2):
            var offset =  Vector2(max_range - x, max_range - y)
            var target_coord = _origin_coord + offset
            
            var distance = abs(offset.x) + abs(offset.y)
            if distance > _movement_range or target_coord == _origin_coord:
                continue
            
            var point = _map.map_to_world(target_coord)
            var shape = get_outer_points(target_coord)
            if distance <= _attack_range:
                if !_attack_points.has(point):
                    _attack_points.append(shape)
            elif !_exclusions.has(target_coord):
                if !_movement_points.has(point):
                    _movement_points.append(shape)
    
    update()
    
    
func get_outer_points(coord:Vector2):
    var points = []
    var world_position = _map.map_to_world(coord)
    
    points.append(world_position + Vector2(0, PADDING))
    points.append(world_position + Vector2((_x * -1) + (PADDING * 2), _y))
    points.append(world_position + Vector2(0, (_y * 2) - PADDING))
    points.append(world_position + Vector2(_x - (PADDING * 2), _y))
    
    return points
    

extends Node2D

const PADDING = 2
const MOVE_COLOR = Color.white
const ATTACK_COLOR = Color.red
const ACTIVE_COLOR = Color.yellow

var _movement_points:Array
var _attack_points:Array
var _movement_range:int = 1
var _attack_range:int = 1
var _origin:Vector2
var _origin_coord:Vector2
var _exclusions:Array
var _show_movement:bool

var _map:TileMap
var _pathfinder:AStarPathfinder
var _x:float
var _y:float

class RangeTile:
    var name:String
    var coord:Vector2
    var points:Array
    var position:Vector2

    func _init(coord, points, position):
        self.coord = coord
        self.points = points
        self.position = position
        name = "range_tile_[%s_%s]" % [coord.x, coord.y]

var _range_tiles:Dictionary = {}
var _active_tile:RangeTile


func setup(map:TileMap, pathfinder:AStarPathfinder):
    _map = map
    _pathfinder = pathfinder
    _x = map.cell_size.x / 2
    _y = map.cell_size.y / 2
    

func activate(unit:Unit, exclusions:Array = [], action_state:String = Action.MOVE):
    # Set range and origin data for the current character.
    _movement_range = unit.character.speed
    _attack_range = unit.character.attack_range
    _origin = unit.position
    _origin_coord = _map.world_to_map(_origin)
    
    # Update exclusions (obstacles) and battle action state.
    _exclusions = exclusions
    _show_movement = action_state == Action.MOVE or action_state == Action.WAIT
    
    # Build all points and draw overlay.
    _get_range_points()

    # Create collisions for mouse interaction.
    _create_all_collisions()


func deactivate():
    _movement_points = []
    _attack_points = []
    update()


func _draw():
    #for tile in _movement_points:
        #draw_polygon(tile.points, PoolColorArray([MOVE_COLOR]))
    
    #for tile in _attack_points:
        #draw_polygon(tile.points, PoolColorArray([ATTACK_COLOR]))
    
    if _active_tile != null:
        draw_polyline(_active_tile.points, ACTIVE_COLOR)


func _get_range_points():
    _movement_points = []
    _attack_points = []
    
    var display_range = _movement_range if _show_movement else _attack_range
    var max_range = clamp(display_range, 2, display_range)
    
    for x in range(max_range * 2):
        for y in range(max_range * 2):

            var offset =  Vector2(max_range - x, max_range - y)
            var abs_offset = Vector2(abs(offset.x), abs(offset.y))
            var target_coord = _origin_coord + offset
            
            var distance = abs_offset.x + abs_offset.y
            if distance > display_range or target_coord == _origin_coord:
                continue
            
            # Create a reference to this tile's shape, location, and coordinates
            # for future drawing and collision detection (mouse).
            var world_pos = _map.map_to_world(target_coord)
            var points = _get_outer_points(target_coord)
            var tile = RangeTile.new(target_coord, points, world_pos)
            
            if abs_offset.x <= _attack_range and abs_offset.y <= _attack_range and !_show_movement:
                # Render these tiles in red (attack)
                if !_attack_points.has(tile):
                    _attack_points.append(tile)
            elif !_exclusions.has(target_coord) and _show_movement:
                # Render these tiles in white (movement)
                if !_movement_points.has(tile):
                    _movement_points.append(tile)
    
    # Redraw the shapes based on gathered points
    update()
    
    
func _get_outer_points(coord:Vector2):
    var points = []
    var world_position = _map.map_to_world(coord)
    
    points.append(world_position + Vector2(0, PADDING))
    points.append(world_position + Vector2((_x * -1) + (PADDING * 2), _y))
    points.append(world_position + Vector2(0, (_y * 2) - PADDING))
    points.append(world_position + Vector2(_x - (PADDING * 2), _y))
    
    return points


func _create_all_collisions():
    var all_points = _movement_points + _attack_points
    var all_keys = []
    for tile in all_points:
        all_keys.append(tile.name)

    for child in get_children():
        # Only erase children which are longer found in all_keys.
        if !all_keys.has(child.name):
            _range_tiles.erase(child.name)
            child.queue_free()
    
    # Create and add all new collision areas.
    for tile in all_points:
        # Only create new collisions if they don't already exist.
        if !_range_tiles.keys().has(tile.name):
            _create_collision(tile)
    

func _create_collision(tile):
    var area = Area2D.new()
    var shape = CollisionPolygon2D.new()

    shape.polygon = tile.points
    area.add_child(shape)
    area.name = tile.name
    print(area.name)

    add_child(area)
    area.world_position = tile.position
    area.connect("area_entered", self, "_on_area_entered")
    area.connect("area_exited", self, "_on_area_exited")

    # Add this as an entry to the reference dictionary by name in order
    # to access it easily/quickly in future mouse events.
    _range_tiles[area.name] = tile


func _on_area_entered(area):
    print("ENTERED %s" % area.name)
    _active_tile = _range_tiles[area.name]


func _on_area_exited():
    _active_tile = null
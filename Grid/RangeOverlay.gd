extends Node2D

const PADDING = 10
const MOVE_COLOR = Color.white - Color(0, 0, 0, .8)
const ATTACK_COLOR = Color.red - Color(0, 0, 0, .8)
const ACTIVE_COLOR = Color.white - Color(0, 0, 0, .5)

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

var tile_change_time

class RangeTile:
    var name:String
    var coord:Vector2
    var points:Array
    var location:Vector2
    var area:Area2D
    var parent

    func _init(coord, points, parent):
        self.coord = coord
        self.points = points
        self.parent = parent
        name = "range_tile_[%s_%s]" % [coord.x, coord.y]
    
    
    func connect_area():
        area.connect("area_entered", self, "_on_area_entered")
        #area.connect("area_exited", self, "_on_area_exited")
    
    
    func _on_area_entered(area):
        if area.name == 'Cursor':
            parent.on_range_tile_entered(self)


    func _on_area_exited(area):
        if area.name == 'Cursor':
            parent.on_range_tile_entered(null)
        

var _range_tiles:Dictionary = {}
var _active_tile:RangeTile


func _ready():
    SignalManager.connect("range_tile_entered", self, "_on_range_tile_entered")
    
    # Used to debounce entering/exiting areas to prevent
    # entering from being canceled out by exiting.
    tile_change_time = OS.get_ticks_msec()
    

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
    _range_tiles = {}
    _active_tile = null
    
    for child in get_children():
        child.free()
    
    update()


func _draw():
    for tile in _movement_points:
        draw_polygon(tile.points, PoolColorArray([MOVE_COLOR]), [], null, null, true)
    
    for tile in _attack_points:
        draw_polygon(tile.points, PoolColorArray([ATTACK_COLOR]))
    
    if _active_tile != null and _show_movement:
        draw_polyline(_active_tile.points + [_active_tile.points[0]], ACTIVE_COLOR, 3, true)


func _get_range_points():
    _movement_points = []
    _attack_points = []
    
    var display_range = _movement_range if _show_movement else _attack_range
    var max_range = clamp(display_range, 2, display_range)
    
    for x in range(max_range * 2):
        for y in range(max_range * 2):

            var offset =  Vector2(max_range - x, max_range - y)
            var target_coord = _origin_coord + offset
            
            var distance = abs(offset.x) + abs(offset.y)
            if distance > max_range or target_coord == _origin_coord:
                continue
            print(distance, " V ", max_range)
            
            # Create a reference to this tile's shape, location, and coordinates
            # for future drawing and collision detection (mouse).
            var world_pos = _map.map_to_world(target_coord)
            var points = _get_outer_points(target_coord)
            var tile = RangeTile.new(target_coord, points, self)
 
            if !_show_movement:
                # Render these tiles in red (attack)
                if !_attack_points.has(tile):
                    _attack_points.append(tile)
            elif !_exclusions.has(target_coord):
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
            var shape = CollisionPolygon2D.new()
            shape.polygon = tile.points
            
            var area = Area2D.new()
            area.add_child(shape)
            area.name = tile.name
            area.transform = Transform2D(0, tile.location)
            
            tile.area = area
            tile.connect_area()
            add_child(area)
            
            
            # Add this as an entry to the reference dictionary by name in order
            # to access it easily/quickly in future mouse events.
            _range_tiles[tile.name] = tile
    

func on_range_tile_entered(tile):
    _active_tile = tile
    update()
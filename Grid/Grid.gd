extends Node2D

var _pathfinder:AStarPathfinder

# Reference to the parent battle for checking if units
# can take actions or not.
var _battle

# Tiles
enum { TILE_NONE = -1, TILE_GRASS = 0 }
var _tile_focused

# Character Units
var Unit = preload("res://Grid/Unit/Unit.tscn")
var unit_selected
var units:Array setget , _get_units

# Cache node
onready var map = $TileMap
onready var camera = $Camera
onready var range_overlay = $RangeOverlay
onready var p_start = $PlayerStart
onready var e_start = $EnemyStart
onready var t_root = $TelegraphRoot
onready var y_sort = $YSort


func _ready():
    _battle = get_parent()
    _pathfinder = AStarPathfinder.new(map)
    
    range_overlay.setup(map, _pathfinder)
    

# Create the units for the grid based on the characters given.
func add_characters(characters:Array, is_enemies = false):
    var walkable_tiles = _pathfinder.walkable_tiles()
    var cell_offset = map.cell_size.y / 2
    var start_position = map.world_to_map(e_start.position if is_enemies else p_start.position)

    for i in range(characters.size()):
        var coords:Vector2 = Vector2(i, 0) + start_position
        var character:Character = characters[i]
        
        var tile_position = map.map_to_world(coords)
        var unit_position = Vector2(tile_position.x, tile_position.y + cell_offset)
        var unit = Unit.instance()
        unit.setup(unit_position, coords, character, is_enemies)
        y_sort.add_child(unit)


# UNIT ACTICATION
# -----------------------------

# Activate the unit that holds the given character.
func activate_character(character:Character):
    if character == null or (is_instance_valid(unit_selected) and unit_selected.character == character):
        return unit_selected

    for unit in self.units:
        if character.id == unit.character.id:
            unit_selected = unit
            unit_selected.activate()
            camera.set_target(unit_selected.position)
        else:
            unit.deactivate()
    
    return unit_selected


func activate_unit(unit):
    if unit_selected == unit:
        return
        
    unit_selected = unit
    unit_selected.activate()
            

func deactivate():
    range_overlay.deactivate()
    SignalManager.emit_signal("tile_focused", [])


# TELEGRAPHS
# -----------------------------
    
func show_movement_overlay():    
    # Show the telegraph of the character's movement
    range_overlay.activate(unit_selected, _get_unit_positions(), Action.MOVE)
    unit_selected.set_animation("Idle")
    

func show_attack_overlay():
    # Show the telegraph of the character's attack
    range_overlay.activate(unit_selected, _get_unit_positions(), Action.ATTACK)
    unit_selected.set_animation("Attack")


# INPUT
# -----------------------------

func _unhandled_input(event):
    if event is InputEventMouse:
        var mouse_position = get_global_mouse_position()
        var tile = map.world_to_map(mouse_position)
        
        if event is InputEventMouseButton:
            # Mouse CLICK tile (selection)
            if event.button_index == BUTTON_LEFT and event.is_pressed():
                select_tile(tile)
        
        elif event is InputEventMouseMotion and \
            unit_selected != null and \
            is_instance_valid(unit_selected) and \
            not unit_selected.is_enemy and \
            _battle.action_state == Action.MOVE:
                # Mouse OVER tile (focus)
                focus_tile(tile)


# TILE SELECTION
# -----------------------------

# Disable units from receving mouse input to allow
# full movement options and not block tiles.
func mouse_ignore_units(value):
    for unit in self.units:
        pass #unit.mouse

# Focus a tile so that a line path can be previewed.
func focus_tile(tile):
    if _tile_focused == tile or unit_selected == null:
        return
        
    if _battle.action_state != Action.MOVE:
        SignalManager.emit_signal("tile_focused", [])
        _tile_focused = tile
        return
    
    var tile_position = map.map_to_world(tile)
    var path = _pathfinder.find_path(\
        unit_selected.position,\
        tile_position,\
        unit_selected.character.speed,\
        _get_unit_positions())
    
    SignalManager.emit_signal("tile_focused", path)
    
    _tile_focused = tile


# Activate a tile or move a unit if already active.
func select_tile(tile):    
    var tile_position = map.map_to_world(tile)
    
    # Check if there is a unit occupying this tile...
    var unit_on_tile = _get_unit_on_tile(tile)     
    if unit_on_tile != null:
        if unit_selected != unit_on_tile:
            if _battle.action_state == Action.ATTACK:
                return
            else:
                pass
                # Select the character and do NOT start pathfinding.
                # Wait for battle to initiate movement again.
                # SignalManager.emit_signal("character_selected", unit_on_tile.character)
                # activate_unit(unit_on_tile)
    
    elif unit_selected != null and not unit_selected.is_enemy:
        # If a unit is already selected, do pathfinding for that unit.
        if _battle.action_state == Action.MOVE and _battle.character_move():
            var new_path = _pathfinder.find_path(\
                unit_selected.position,\
                tile_position,\
                unit_selected.character.speed,\
                _get_unit_positions())
            unit_selected.path = new_path
            unit_selected.coord = map.world_to_map(new_path[new_path.size() - 1])
            
            deactivate()


# ENEMIES
# -----------------------------

func move_to_nearest_unit(origin_unit) -> bool:  
    var target_unit = get_nearest_unit(origin_unit)
    
    if origin_unit == null or target_unit == null:
        return false
        
    var distance = get_coord_distance(origin_unit.position, target_unit.position).length()
    if distance <= 1:
        return false
          
    var obstacle_positions = _get_unit_positions([origin_unit, target_unit])    
    var new_path = _pathfinder.find_path(\
        origin_unit.position,\
        target_unit.position,\
        origin_unit.character.speed,\
        obstacle_positions)
    
    if new_path.size() == 0:
        return false
    
    # Take the last piece of the path off if it's the tile the
    # target is currently occupying
    var last_point = new_path[new_path.size() - 1]
    if map.world_to_map(last_point) == map.world_to_map(target_unit.position):
        new_path.pop_back()
    
    origin_unit.path = new_path
    return true


# Get the unit nearest to the origin character.
func get_nearest_unit(origin_unit):
    var origin_tile = map.world_to_map(position)
    var min_distance:float = 9999
    var target
    
    for unit in self.units:
        if unit != origin_unit and unit.character.is_enemy != origin_unit.character.is_enemy:
            var enemy_tile = map.world_to_map(unit.position)
            var distance = origin_tile.distance_to(enemy_tile)
            if distance < min_distance:
                min_distance = distance
                target = unit
    
    return target


# HELPERS
# -----------------------------

func get_unit_by_character(character):
    for unit in self.units:
        if unit.character == character:
            return unit


func get_coord_distance(start, end):
    return map.world_to_map(start) - map.world_to_map(end)


func _get_unit_on_tile(tile):
    # Check if there is a unit occupying this tile...
    for unit in self.units:
        if tile == map.world_to_map(unit.position):
            return unit

    # No unit on this tile
    return null

   
func _get_unit_positions(exceptions = []):
    var positions = []
    #for unit in units:
    for unit in self.units:
        if unit != unit_selected and !exceptions.has(unit):
            positions.append(map.world_to_map(unit.path_end))
        
    return positions


# GETTERS
# -----------------------------

func _get_units():
    return get_tree().get_nodes_in_group("units")

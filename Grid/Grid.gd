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
var units = []

# Cache node
onready var map = $TileMap
onready var camera = $Camera


func _ready():
    _battle = get_parent()
    _pathfinder = AStarPathfinder.new(map)


# Create the units for the grid based on the characters given.
func add_characters(characters:Array):
    var walkable_tiles = _pathfinder.walkable_tiles()
    var cell_offset = map.cell_size.y / 2
    
    for i in range(characters.size()):
        var coords:Vector2 = walkable_tiles[i]
        var character:Character = characters[i]
        
        var tile_position = map.map_to_world(coords)
        var unit_position = Vector2(tile_position.x, tile_position.y + cell_offset)
        var unit = Unit.instance()
        unit.setup(unit_position, character)
        add_child(unit)
        units.append(unit)


# Activate the unit that holds the given character.
func activate_character(character):
    if unit_selected != null and unit_selected.character == character:
        return

    for unit in units:
        if character.id == unit.character.id:
            unit_selected = unit
            unit_selected.activate()
            camera.set_target(unit_selected.position)
        else:
            unit.deactivate()


func activate_unit(unit):
    if unit_selected == unit:
        return
        
    unit_selected = unit
    unit_selected.activate()
            

func deactivate():
    SignalManager.emit_signal("tile_focused", [])


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
        _battle.action_state == Action.MOVE:
            # Mouse OVER tile (focus)
            focus_tile(tile)


func focus_tile(tile):
    if _tile_focused == tile or unit_selected == null:
        return
    
    var tile_position = map.map_to_world(tile)
    var path = _pathfinder.find_path(\
    unit_selected.position,\
    tile_position,\
    unit_selected.character.speed,\
    _get_unit_positions())
    
    SignalManager.emit_signal("tile_focused", path)
    
    _tile_focused = tile

 
func select_tile(tile):    
    var tile_position = map.map_to_world(tile)
    
    # Check if there is a unit occupying this tile...
    var unit_on_tile = _get_unit_on_tile(tile)     
    if unit_on_tile != null:
        if unit_selected != unit_on_tile:
            
            if _battle.action_state == Action.ATTACK:
                # Selected character is trying to attack someone...
                var unit_position = map.world_to_map(unit_selected.position)
                var distance = (tile - unit_position).length()
                _battle.character_attack(unit_on_tile.character, distance)
            else:
                # Select the character and do NOT start pathfinding.
                # Wait for battle to initiate movement again.
                SignalManager.emit_signal("character_selected", unit_on_tile.character)
                activate_unit(unit_on_tile)
    
    elif unit_selected != null:
        # If a unit is already selected, do pathfinding for that unit.
        if _battle.character_move():
            var new_path = _pathfinder.find_path(\
            unit_selected.position,\
            tile_position,\
            unit_selected.character.speed,\
            _get_unit_positions())
            unit_selected.path = new_path
            
            deactivate()


func _get_unit_on_tile(tile):
    # Check if there is a unit occupying this tile...
    for unit in units:
        if tile == map.world_to_map(unit.position):
            return unit

    # No unit on this tile
    return null

   
func _get_unit_positions():
    var positions = []
    for unit in units:
        if unit != unit_selected:
            positions.append(map.world_to_map(unit.path_end))
        
    return positions


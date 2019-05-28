extends Node

signal teams_loaded(heroes, enemies)

signal tile_focused(path)
signal character_selected(character)
signal unit_targeted(unit)
signal unit_movement_done()
signal telegraph_executed(units)

signal turn_updated(turn)
signal battle_state_updated(state)

signal health_changed(character)
signal stat_changed(character)

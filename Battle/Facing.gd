extends Node

class_name Facing

const UP = Vector2.UP        # (0, -1)
const DOWN = Vector2.DOWN    # (0, 1)
const LEFT = Vector2.LEFT    # (-1, 0)
const RIGHT = Vector2.RIGHT  # (1,  0)
const UP_RIGHT = Vector2(1, -1)
const UP_LEFT = Vector2(-1, -1)
const DOWN_RIGHT = Vector2(1, 1)
const DOWN_LEFT = Vector2(-1, 1)

const FRONT = "FRONT"
const BEHIND = "BEHIND"
const FLANK_RIGHT = "RIGHT"
const FLANK_LEFT = "LEFT"


# Get the facing of a directional vector relatic to an incoming direction
static func get_relative_facing(target, tile:Vector2) -> String:
    var offset = (tile - target.coord).normalized()
    
    match(target.facing):
        UP: # ---------- ^ -----------
            match(offset):
                UP: return FRONT
                DOWN: return BEHIND
                LEFT: return FLANK_LEFT
                RIGHT: return FLANK_RIGHT
        DOWN:# ---------- v -----------
            match(offset):
                UP: return BEHIND
                DOWN: return FRONT
                LEFT: return FLANK_RIGHT
                RIGHT: return FLANK_LEFT
        RIGHT: # ---------- > ----------
            match(offset):
                UP: return FLANK_LEFT
                DOWN: return FLANK_RIGHT
                LEFT: return BEHIND
                RIGHT: return FRONT
        LEFT: # ---------- < ----------
            match(offset):
                UP: return FLANK_RIGHT
                DOWN: return FLANK_LEFT
                LEFT: return FRONT
                RIGHT: return BEHIND
        
    return ""
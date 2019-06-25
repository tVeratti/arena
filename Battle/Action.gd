extends Object

class_name Action

const PRIMARY = "PRIMARY"
const SECONDARY = "SECONDARY"
const FREE = "FREE"


const MOVE = "MOVE"
const ATTACK = "ATTACK"
const ANALYZE = "ANALYZE"
const WAIT = "WAIT"
const FREEZE = "FREEZE"

const GROUPS = {
    ATTACK: PRIMARY,
    ANALYZE: PRIMARY,
    MOVE: SECONDARY,
    WAIT: FREE,
    FREEZE: FREE
}
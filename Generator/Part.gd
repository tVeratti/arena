extends Object

class_name Part

# Node names
const HEAD = "head"
const HAIR = "hair"
const WAIST = "waist"
const TORSO = "torso"
const R_ARM = "r_arm"
const R_FOREARM = "r_forearm"
const R_HAND = "r_hand"
const L_ARM = "l_arm"
const L_FOREARM = "l_forearm"
const L_HAND = "l_hand"
const R_THIGH = "r_thigh"
const R_SHIN = "r_shin"
const R_FOOT = "r_foot"
const L_THIGH = "l_thigh"
const L_SHIN = "l_shin"
const L_FOOT = "l_foot"

var name:String
var texture:Texture
var polygon:PoolVector2Array

func _init(source:Node2D):
    if source is Polygon2D:
        self.name = source.name
        self.polygon = source.polygon
    
    
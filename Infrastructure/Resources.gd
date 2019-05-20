extends Node

const base_m_01 = preload("res://Character/textures/spritesheets/base_m_01.png")
const base_m_02 = preload("res://Character/textures/spritesheets/base_m_02.png")
const base_m_03 = preload("res://Character/textures/spritesheets/base_m_03.png")

const nin_m_01 = preload("res://Character/textures/spritesheets/nin_m_01.png")

const spritesheet_path = "res://Character/textures/spritesheets"
var spritesheets = [] setget , _get_spritesheets


func _get_spritesheets():
    if spritesheets.size() > 0: return spritesheets
    spritesheets = [
        base_m_01,
        base_m_02,
        base_m_03,
        nin_m_01
    ]
    
    #var directory = Directory.new()
    #directory.open(spritesheet_path)
    #directory.list_dir_begin()
    #while true:
        #var file = directory.get_next()
        #if file == "": break
        #elif file.ends_with(".png"):
            #spritesheets.append(load(spritesheet_path + "/" + file))

    #directory.list_dir_end()
    
    return spritesheets

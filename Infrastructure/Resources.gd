extends Node

const spritesheet_path = "res://Character/textures/spritesheets"
var spritesheets = [] setget , _get_spritesheets


func _get_spritesheets():
    if spritesheets.size() > 0: return spritesheets
    spritesheets = []
    
    var directory = Directory.new()
    directory.open(spritesheet_path)
    directory.list_dir_begin()
    while true:
        var file = directory.get_next()
        if file == "": break
        elif file.ends_with(".png"):
            spritesheets.append(load(spritesheet_path + "/" + file))

    directory.list_dir_end()
    
    return spritesheets

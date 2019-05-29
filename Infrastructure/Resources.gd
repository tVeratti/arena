extends Node


const spritesheet_path = "res://Character/textures/spritesheets"
var spritesheets:Dictionary setget , _get_spritesheets

func _get_spritesheets():
    if spritesheets.keys().size() > 0: return spritesheets
    
    var textures = {}
    var dir = Directory.new()
    if dir.open(spritesheet_path) == OK:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while (file_name != ""):
            # Open each part folder and load all textures.
            if dir.current_is_dir() and !file_name.begins_with("."):
                textures[file_name] = _get_part_textures(file_name)

            # Next part folder...
            file_name = dir.get_next()                 

    dir.list_dir_end()

    spritesheets = textures
    return spritesheets


func _get_part_textures(part_dir_path) -> Array:
    var textures = []
    
    var dir = Directory.new()
    if dir.open(spritesheet_path + "/" + part_dir_path) == OK:
        dir.list_dir_begin()
        
        var file_name = dir.get_next()
        while (file_name != ""):
            var resource_file = ""
            
            # Load the texture .png into the current array.
            if file_name.ends_with(".import"): #Export
                resource_file = file_name.replace(".import", "")
            elif file_name.ends_with(".png"): # Editor
                resource_file = file_name
            
            if resource_file != "":
                var type_name = resource_file.replace(".png", "")
                var texture = load("%s/%s/%s" % [spritesheet_path, part_dir_path, resource_file])
                textures.append(texture)
            
            # Next texture file...
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    return textures

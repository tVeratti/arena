extends Node2D


func get_sprite_details() -> Part:
    return read_sprite($Sprites)


func read_sprite(node:Node2D) -> Part:
    # Recursively read all child sprites until end.
    # Turn each sprite into the needed parts (texture, region, children).
    var children = []
    for child in node.get_children():
        if child is Sprite:
            children.append(read_sprite(child))
    
    return Part.new(node, children)

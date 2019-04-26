extends Node2D


func _ready():
    $AnimationPlayer.play("idle")


func get_sprite_dictionary() -> Dictionary:
    var all_nodes = {}
    all_nodes["root"] = read_polygon($parts, all_nodes)
    return all_nodes


func read_polygon(node:Node2D, root:Dictionary) -> Part:
    # Recursively read all child sprites until end.
    # Turn each sprite into the needed parts (texture, region, children).
    for child in node.get_children():
        if child is Polygon2D:
            root[child.name] = read_polygon(child, root)
    
    return Part.new(node)

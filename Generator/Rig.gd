extends Node2D


func _ready():
    $AnimationPlayer.play("idle")


func get_sprite_dictionary() -> Dictionary:
    var all_nodes = {}
    all_nodes["root"] = read_sprite($Sprites, all_nodes)
    return all_nodes


func read_sprite(node:Node2D, root:Dictionary) -> Part:
    # Recursively read all child sprites until end.
    # Turn each sprite into the needed parts (texture, region, children).
    for child in node.get_children():
        if child is Sprite:
            root[child.name] = read_sprite(child, root)
    
    return Part.new(node)

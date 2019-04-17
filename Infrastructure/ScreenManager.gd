extends Node

var main:Node

func change_to(scene_path:String, props = null):
    # Remove previous child scene
    for child in main.get_children():
        child.queue_free()
    
    # Instance and add new scene
    var scene = load(scene_path)
    var new_scene = scene.instance()
    main.add_child(new_scene)
    if props != null:
        new_scene.setup(props)
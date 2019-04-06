extends StaticBody2D

var _size:int = 128
var _coordinates:Vector2
var grid_position:Vector2

func _ready():
    print("hi")

func setup(x = 0, y = 0, size = 128):
    _coordinates = Vector2(x, y)
    _size = size
    
    # Set 2D graphical position based on coordinates & size
    position = Vector2(x * _size, y * _size)
    

func _on_Tile_input_event(viewport, event, shape_idx):
    print(event)
    if event.is_pressed():
        if event.button_index == BUTTON_LEFT:
            SignalManager.emit_signal("tile_selected", self)


func _on_Tile_mouse_entered():
    print("hello")
    SignalManager.emit_signal("tile_focused", self)

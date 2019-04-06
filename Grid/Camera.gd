extends Camera2D

# Anything above 1.0 zooms in, anything below 1.0 zooms out.
var _zoom_in = Vector2(1.1, 1.1)
var _zoom_out = Vector2(0.9, 0.9)
    
func _ready():
    SignalManager.connect("tile_selected", self, "_on_Tile_selected")

func _input(event):
    if event.is_pressed():
        if event.button_index == BUTTON_WHEEL_UP:
            zoom = _zoom_in
        elif event.button_index == BUTTON_WHEEL_DOWN:
            zoom = _zoom_out
            
func _on_Tile_selected(Tile):
    pass #align(Tile)
            
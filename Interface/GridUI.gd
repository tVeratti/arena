extends CanvasLayer

onready var Distance = $Layout/Rows/Columns/Distance

# Called when the node enters the scene tree for the first time.
func _ready():
    SignalManager.connect("tile_focused", self, "_on_tile_focused")

func _on_tile_focused(tile, path):
    Distance.text = "Distance: %s" % path.size()

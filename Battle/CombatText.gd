extends Node2D


var _value
var _extra
var _color

onready var _value_label = $Values/Value
onready var _extra_label = $Values/Extra

func _ready():
    _value_label.text = _value
    _extra_label.text = _extra
    
    _value_label.add_color_override("font_color", _color)
    _extra_label.add_color_override("font_color", _color)
    
    $Values.show()
    $EndTimer.start(2)
    $FadeTimer.start(1)
    $AnimationPlayer.play("Fade")


func setup(value, extra, color = Color.white):
    _value = String(value)
    _extra = String(extra)
    _color = color


func _on_EndTimer_timeout():
    queue_free()


func _on_FadeTimer_timeout():
    $Tween.interpolate_property(
        self,
        "modulate", 
        Color(1, 1, 1, 1),
        Color(1, 1, 1, 0),
        1, 
        Tween.TRANS_LINEAR,
        Tween.EASE_IN)
        
    $Tween.start()

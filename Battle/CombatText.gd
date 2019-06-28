extends Node2D

onready var _value = $Values/Value
onready var _extra = $Values/Extra

func _ready():
    $Values.show()


func setup(value, extra, color):
    _value.text = String(value)
    _extra.text = String(extra)
    
    _value.add_color_override("font_color", color)
    _extra.add_color_override("font_color", color)
    
    $EndTimer.start(2)
    $FadeTimer.start(1)
    $AnimationPlayer.play("Fade")


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

extends Node2D

onready var _value = $Values/Value
onready var _extra = $Values/Extra

func setup(value, extra):
    _value.text = String(value)
    _extra.text = String(extra)
    
    $Timer.start(1)
    $AnimationPlayer.play("Fade")
        

func _on_Timer_timeout():
    queue_free()

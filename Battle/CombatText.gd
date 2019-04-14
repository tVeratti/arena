extends Node2D

onready var _damage = $Values/Damage
onready var _bonus = $Values/Bonus

func setup(damage, multiplier):
    _damage.text = String(damage)
    _bonus.text = ""
    
    if multiplier > 1:
        _bonus.text = "x%s" % multiplier
        
    $Timer.start(1)
    $AnimationPlayer.play("Fade")
        

func _on_Timer_timeout():
    queue_free()

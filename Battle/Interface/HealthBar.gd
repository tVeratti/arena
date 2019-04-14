extends Node2D

onready var _tween = $Tween
onready var _progress = $Progress
onready var _timer = $Timer

var id:String
var health:int = 100


func _ready():
    SignalManager.connect("health_changed", self, "_on_health_changed")
    hide()


func setup(character):
    id = character.id
    health = character.health.value_current
    
    $Progress.max_value = character.health.value_maximum
    $Progress.value = health


func set_health(new_health):
    show()
    _tween.interpolate_property(_progress, "value", health, new_health, 1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
    _tween.start()
    _timer.start(1.3)
    health = new_health


func _on_health_changed(character):
    if character.id == id:
        set_health(character.health.value_current)


func _on_Timer_timeout():
    hide()

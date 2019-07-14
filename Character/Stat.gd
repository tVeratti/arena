extends Object

class_name Stat

var character

var name:String
var value:int setget , _value_get

var base:int = 1
var rank:int = 1

# Progress range [0.0 - 1.0]
var progress:float = 0.0
var progress_factor:float = 1.0


func _init(name:String, progress_factor:int, character):
    self.name = name
    self.progress_factor = progress_factor
    self.character = character


func add_progress(amount:float):
    var progress_step:float = amount / progress_factor / rank
    var progress_new:float = progress + progress_step
    if (progress_new >= 1):
        var carry_over = max(0, progress_new - 1)
        progress = 0
        rank_up()
        add_progress(carry_over * progress_factor)
    else:
        progress = progress_new


func rank_up():
    rank += 1
    SignalManager.emit_signal("ranked_up", character, self)


func _value_get():
    return base + rank
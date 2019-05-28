extends HBoxContainer

var stat:Stat
var character:Character

onready var label = $Label
onready var button = $Button
onready var progress = $ProgressBar


func set_stat(stat:Stat, character:Character):
    self.stat = stat
    self.character = character
    update_ui()


func update_ui():
    label.text = "%s (%s)" % [stat.name, stat.rank]
    progress.value = stat.progress


func _on_Button_pressed():
    character.progress_stat(stat.name, 1.5)
    update_ui()

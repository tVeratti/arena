extends MarginContainer

var stat:Label
var value:Label
var diff:Label
var arrow:TextureRect


func _ready():
    var layout = $MarginContainer/Layout
    stat = layout.get_node("Label")
    value = layout.get_node("Value")
    diff = layout.get_node("Difference")
    arrow = layout.get_node("ArrowContainer/Arrow")


func set_data(label, target_stat, attacker_stat):
    # Target Stat
    stat.text = label
    value.text = String(target_stat)
    
    if target_stat != attacker_stat:
        # Difference
        var target_greater = target_stat > attacker_stat
        var color  = Color.red if target_greater else Color.green
        var operator = "+" if target_greater else "-"
        #var rotation = 180 if target_greater else 0
        diff.text = "%s%s" % [operator, abs(target_stat - attacker_stat)]
        diff.add_color_override("font_color", color)
        
        #arrow.show()
        #arrow.rect_rotation = rotation
        #arrow.modulate = color
    else:
        # Same Value
        diff.text = "--"
        diff.add_color_override("font_color", Color.white)
        #arrow.hide()
        
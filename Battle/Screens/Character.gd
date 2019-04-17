extends VBoxContainer

func setup(character):
    $Layout/Image.texture = character.portrait_texture
    $Layout/Details/Name.text = character.name if character.is_alive else "%s (DECEASED)" % character.name
    $Health.value = \
        character.health.value_current / \
        character.health.value_maximum * 100
    
    if !character.is_enemy:
        $Layout/Details/Speed.text = "Speed - %s" % character.speed
        $Layout/Details/Toughness.text = "Toughness - %s" % character.toughness
        $Layout/Details/Power.text = "Power - %s" % character.power
    
    else:
        $Layout/Details/Speed.text = "%s - Speed" % character.speed
        $Layout/Details/Toughness.text = "%s - Toughness" % character.toughness
        $Layout/Details/Power.text = "%s - Power" % character.power
        
        $Layout.move_child($Layout/Details, 0)
        for label in $Layout/Details.get_children():
            label.align = ALIGN_BEGIN

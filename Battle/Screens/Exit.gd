extends CanvasLayer

var CharacterInfo = preload("res://Battle/Screens/Character.tscn")

func setup(battle):
    
    var heroList = get_node("Container/Layout/Characters/Heroes")
    var enemyList = get_node("Container/Layout/Characters/Enemies")

    $Container/Layout/Resolution.text = "Victory!" if battle.winner == "player" else "Defeat"
    
    for character in battle.heroes:
        var character_info = CharacterInfo.instance()
        heroList.add_child(character_info)
        character_info.setup(character)
    
    for character in battle.enemies:
        var character_info = CharacterInfo.instance()
        enemyList.add_child(character_info)
        character_info.setup(character)


func _on_Exit_pressed():
    get_tree().quit()

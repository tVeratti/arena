extends CanvasLayer

var CharacterInfo = preload("res://Battle/Screens/Character.tscn")
var _battle;

func setup(battle):
    _battle = battle
    
    var heroList = get_node("Container/Layout/Characters/Heroes")
    var enemyList = get_node("Container/Layout/Characters/Enemies")
    
    for character in battle.heroes:
        var character_info = CharacterInfo.instance()
        heroList.add_child(character_info)
        character_info.setup(character)
    
    for character in battle.enemies:
        var character_info = CharacterInfo.instance()
        enemyList.add_child(character_info)
        character_info.setup(character)


func _on_Start_pressed():
    ScreenManager.change_to(Scenes.BATTLE_MAIN, _battle)

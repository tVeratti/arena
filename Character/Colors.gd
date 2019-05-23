extends Object

const colors_shader = preload("res://Assets/colors.shader")

const HAIR = [
    '88292F',
    'A77464',
    '80FFEC',
    'EE4B6A',
    'EF8354',
    '52FFB8',
    'F4F1BB',
    '6B6D76',
    '554971',
    '82DDF0',
    'DBFF76',
    'F4F4EB'
]

const SKIN = [
    '8D5524',
    'C68642',
    'E0AC69',
    'F1C27D',
    'FFDBAC'
]

const CLOTHES = [
    '922D50',
    'B8C480',
    'AF9164',
    'DEB841',
    '6D6A75',
    '9DC0BC',
    '7C7287',
    'B2EDC5',
    '5F464B',
    'C2FBEF',
    'D8A47F',
    '1B5299',
    '9FC2CC',
    'E6EBE0',
    '726E60'
]

const EYES = [
    '819595',
    '634e34',
    '2e536f',
    '3d671d',
    '1c7847',
    '497665',
    '5D4E6D',
    'C1FFF2',
    'EE4B6A',
    'EF8354',
    'FAB2EA'
]

const DARKEN_RANGE = 0.5
const LIGHTEN_RANGE = 0.5

static func set_shader_params(material, colors) -> void:
    material.shader = colors_shader
    
    material.set_shader_param("hair_normal", colors.hair[0])
    material.set_shader_param("hair_shadow", colors.hair[1])
    
    material.set_shader_param("skin_normal", colors.skin[0])
    material.set_shader_param("skin_shadow", colors.skin[1])
    
    material.set_shader_param("clothes_normal", colors.clothes[0])
    material.set_shader_param("clothes_shadow", colors.clothes[1])
    
    material.set_shader_param("eyes", colors.eyes[0])


static func random_hair() -> Array:
    return random_color(HAIR)


static func random_skin() -> Array:
    return random_color(SKIN)


static func random_clothes() -> Array:
    return random_color(CLOTHES)


static func random_eyes() -> Array:
    return random_color(EYES)


static func random_color(array):
    var index = _rand(array.size())
    var color = as_color(array[index])
    var do_lighten = _rand(2) % 2 == 0
    if do_lighten: color = color.lightened(_rand_lighten())
    else: color = color.darkened(_rand_darken())
    
    return [color, color.darkened(0.5)]


static func as_color(hex):
    return Color("#%s" % hex)


static func _rand(limit):
    return int(rand_range(0.0, limit))


static func _rand_lighten():
    return rand_range(0.0, LIGHTEN_RANGE)


static func _rand_darken():
    return rand_range(0.0, DARKEN_RANGE)
    

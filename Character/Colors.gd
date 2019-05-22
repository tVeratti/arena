extends Object

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

static func random_hair():
    var index = int(rand_range(0.0, HAIR.size()))
    return as_color(HAIR[index])


static func random_skin():
    var index = int(rand_range(0.0, SKIN.size()))
    return as_color(SKIN[index])


static func random_clothes():
    var index = int(rand_range(0.0, CLOTHES.size()))
    return as_color(CLOTHES[index])


static func random_eyes():
    var index = int(rand_range(0.0, EYES.size()))
    return as_color(EYES[index])


static func as_color(hex):
    return Color("#%s" % hex)

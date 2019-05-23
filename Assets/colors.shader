shader_type canvas_item;

uniform vec4 hair_normal: hint_color;
uniform vec4 hair_shadow: hint_color;

uniform vec4 skin_normal: hint_color;
uniform vec4 skin_shadow: hint_color;

uniform vec4 clothes_normal: hint_color;
uniform vec4 clothes_shadow: hint_color;

uniform vec4 eyes: hint_color;

uniform float tolerance = 0.15;

bool match_key(vec4 a, vec4 key_color, inout float color_distance) {
    vec4 b = vec4(
        key_color.r / 255.0,
        key_color.g / 255.0,
        key_color.b / 255.0,
        1
    );
    
    color_distance = 
        pow((a.r - b.r), 2) + 
        pow((a.g - b.g), 2) +
        pow((a.b - b.b), 2);
        
    return color_distance < tolerance;
}

void fragment() {    
    // Screen key colors
    vec4 key_hair_normal = vec4(255,52,192, 1);
    vec4 key_hair_shadow = vec4(168,0,116, 1);

    vec4 key_skin_normal = vec4(35, 255, 226, 1);
    vec4 key_skin_shadow = vec4(0, 175, 152,1);

    vec4 key_clothes_normal = vec4(157, 255, 0, 1);
    vec4 key_clothes_shadow = vec4(56, 141, 0, 1);

    vec4 key_eyes = vec4(255, 174, 0, 1);
    
    // Get color from the sprite texture at the current pixel we are rendering
    vec4 original_color = texture(TEXTURE, UV);
    
    float color_distance;
    
    // Hair
    if (match_key(original_color, key_hair_normal, color_distance)) COLOR = vec4(hair_normal.rgb, original_color.a);
    else if (match_key(original_color, key_hair_shadow, color_distance)) COLOR = vec4(hair_shadow.rgb, original_color.a);
    // Skin
    else if (match_key(original_color, key_skin_normal, color_distance)) COLOR = vec4(skin_normal.rgb, original_color.a);
    else if (match_key(original_color, key_skin_shadow, color_distance)) COLOR = vec4(skin_shadow.rgb, original_color.a);
    // Clothes
    else if (match_key(original_color, key_clothes_normal, color_distance)) COLOR = vec4(clothes_normal.rgb, original_color.a);
    else if (match_key(original_color, key_clothes_shadow, color_distance)) COLOR = vec4(clothes_shadow.rgb, original_color.a);
    // Eyes
    else if (match_key(original_color, key_eyes, color_distance)) COLOR = vec4(eyes.rgb, original_color.a);
    else {
        COLOR = original_color;
    }
}


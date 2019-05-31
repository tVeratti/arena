shader_type canvas_item;

uniform float tint = 0.2;

void fragment() {
    vec2 uv_def = vec2(UV.x + pow((1.0-UV.y), 2.0) * sin(TIME) * 10.0, UV.y);
    COLOR = texture(TEXTURE, uv_def);
}
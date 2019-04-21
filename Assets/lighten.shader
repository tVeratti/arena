shader_type canvas_item;

uniform float tint = 0.2;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    COLOR = vec4(color.r + tint, color.g + tint, color.b + tint, color.a);
}
shader_type canvas_item;

uniform float tint = 0.2;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    COLOR = vec4(0, 0, 0, color.a);
}
shader_type canvas_item;
uniform float outline_width = 10.0;
uniform vec4 outline_color = vec4(1, 1, 1, 1);

void fragment(){
    vec4 col = texture(TEXTURE, UV);
    vec2 ps = TEXTURE_PIXEL_SIZE * outline_width; // multiply only once instead of eight times.
    float a;
    float maxa = col.a;
    float mina = col.a;

    // Use 8-way kernel for smoothness
    //------------------//
    //    X   X   X     //
    //      \ | /       //
    //    X - O - X     //
    //      / | \       //
    //    X   X   X     //
    //------------------//

    for(float y = -1.0; y <= 1.0; y++) {
        for(float x = -1.0; x <= 1.0; x++) {
            if(vec2(x,y) == vec2(0.0)) {
                continue; // ignore the center of kernel
            }

            a = texture(TEXTURE, UV + vec2(x,y)*ps).a;
            maxa = max(a, maxa); 
            mina = min(a, mina);
        }
    }

    // Fill transparent pixels only, don't overlap texture
    if(col.a < 0.2) {
        COLOR = mix(col, outline_color, maxa-mina);
    } else {
        // Note on old code: if the last mix value is always 0, why even use it?
        COLOR = col;
    }
}
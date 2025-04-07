shader_type canvas_item;

uniform sampler2D existing_screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float contrast : hint_range(0.0, 2.0) = 1.0;     // 1.0 = normal
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;  // 0.0 = normal
uniform float invert_strength : hint_range(0.0, 1.0) = 0.0; // Controlled via COLOR.a

void fragment() {
    vec4 screen_color = texture(existing_screen_texture, SCREEN_UV);

    // Apply contrast (toward mid gray)
    vec3 mid_gray = vec3(0.5);
    vec3 contrasted = mix(mid_gray, screen_color.rgb, contrast);

    // Apply inversion based on alpha (COLOR.a)
    vec3 inverted = vec3(1.0) - contrasted;
    vec3 blended = mix(contrasted, inverted, COLOR.a);

    // Apply brightness adjustment
    vec3 brightened = blended + vec3(brightness);

    COLOR.rgb = clamp(brightened, 0.0, 1.0); // Ensure valid color output
    COLOR.a = 1.0;
}

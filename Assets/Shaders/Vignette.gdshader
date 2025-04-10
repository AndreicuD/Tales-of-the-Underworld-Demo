shader_type canvas_item;

uniform float outerRadius : hint_range(0.0, 5.0) = 1.0;
uniform float MainAlpha : hint_range(0.0, 1.0) = 1.0;
uniform float feathering : hint_range(0.0, 1.0) = 0.1; // Feathering control

void fragment() {
    float x = abs(UV.x - 0.5) * 2.0;
    float y = abs(UV.y - 0.5) * 2.0;
    float v = sqrt((x * x) + (y * y)) / outerRadius;

    // Apply feathering using smoothstep for a soft transition
    float feathered_alpha = smoothstep(1.0 - feathering, 1.0, v);

    // Final alpha with MainAlpha adjustment
    float alpha = feathered_alpha * MainAlpha;

    COLOR = vec4(0, 0, 0, alpha);
}

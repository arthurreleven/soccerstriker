shader_type canvas_item;

uniform sampler2D texture_cbcr : hint_default_black;

void fragment() {
    float y  = texture(TEXTURE, UV).r;
    float cb = texture(texture_cbcr, UV).r - 0.5;
    float cr = texture(texture_cbcr, UV).g - 0.5;
    
    float r = y + 1.402 * cr;
    float g = y - 0.344136 * cb - 0.714136 * cr;
    float b = y + 1.772 * cb;
    
    COLOR = vec4(r, g, b, 1.0);
}
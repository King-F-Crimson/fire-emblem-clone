extern vec3 tint_color;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
    number average = (pixel.r+pixel.b+pixel.g)/3.0;
    pixel.r = average * tint_color[0];
    pixel.g = average * tint_color[1];
    pixel.b = average * tint_color[2];
    return pixel;
}
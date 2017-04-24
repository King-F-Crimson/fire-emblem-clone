extern vec4 start_color;
extern vec4 end_color;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    number factor = texture_coords.x;

    vec4 pixel = start_color * (1 - factor) + end_color * factor;

    return pixel;
}
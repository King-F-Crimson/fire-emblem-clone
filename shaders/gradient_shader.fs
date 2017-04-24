extern vec4 start_color;
extern vec4 end_color;
extern number bar_width;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    // Substract 1 from bar_width so first and last pixel are the start_color and end_color.
    number factor = texture_coords.x / (    bar_width - 1);

    vec4 pixel = start_color * factor + end_color * (1 - factor);

    return pixel;
}
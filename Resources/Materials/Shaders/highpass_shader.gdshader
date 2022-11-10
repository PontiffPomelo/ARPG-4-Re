shader_type canvas_item;

uniform float highpass = 1;
uniform vec4 color_high = vec4(1,1,1,1);
uniform vec4 color_low = vec4(1,1,1,1);


void fragment() 
{
	COLOR = texture(TEXTURE, UV) * COLOR;
	float len = length(COLOR.xyz)/sqrt(3);
	float pass = ceil(len-highpass);
    COLOR = pass * color_high * COLOR + (1.0 - pass) * color_low * COLOR;
}
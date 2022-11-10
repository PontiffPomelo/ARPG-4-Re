shader_type canvas_item;
render_mode unshaded;

uniform vec2 position;
uniform float strength = 1.0;

float angle(vec2 a,vec2 b)
{
	float d = dot(a,b);
	float det = a.x*b.y - b.x*a.y;
	//float c = length(a)*length(b);
	//return d/c;
	return atan(det, d);
}

void fragment()
{
	vec2 dir = vec2(SCREEN_UV.x,SCREEN_UV.y) - position;
	float d = length(dir);
	float rand_x = (sin(angle(dir,vec2(1,0))*40.0 + TIME*3.0)+1.0)/2.0;
	float rand_y = (sin(angle(dir,vec2(1,0))*17.0 - TIME*5.0)+1.0);
	// now radially distort screen UV away from mouse
	float distortion =  max(0,d-0.3) * rand_x*rand_y/40.0  * 5.0*strength;
	COLOR = texture(SCREEN_TEXTURE,position + dir);
	
	COLOR = textureLod(SCREEN_TEXTURE, position + (dir + dir * distortion*d), 8.0*d);
	//COLOR.a = 1.0;
	distortion = clamp(distortion,0.0,1.0);
	COLOR -= max(0,distortion) * COLOR;
	d = clamp(d,0.0,1.0);
	COLOR = (1.0-d) * COLOR + d * vec4(0,0,0,1);	
	COLOR.a = 1.0;
	
	//COLOR = vec4(rand_x,rand_x,rand_x,1);
}
shader_type canvas_item;

uniform float inner_radius : hint_range(0,1) = 0.9;
uniform float outer_radius : hint_range(0,1) = 1;
uniform float progress : hint_range(0,1) = 0.8;

uniform float transition:hint_range(0,0.5) = 0.05;

uniform vec4 active_color : source_color = vec4(.3,.3,1,1);
uniform vec4 hidden_color : source_color = vec4(1,0,0,1);
uniform vec4 fill_color : source_color = vec4(0,0,0,0);


float angle(vec2 a,vec2 b)
{
	float d = dot(a,b);
	float det = a.x*b.y - b.x*a.y;
	return atan(det, d);
}

float mystep(float value, float threshold, float hardness)
{
	float edge0 = threshold - hardness;
	float edge1 = threshold + hardness;
	return clamp((value - edge0) / (edge1 - edge0), 0.0, 1.0); 
}

void fragment()
{
	float dist = length(vec2(UV.x-0.5,UV.y-0.5)) * 2.0;
	float outer_mask = mystep(outer_radius,dist,transition);
	float inner_mask = mystep(dist,inner_radius,transition);
	float circle_mask =  outer_mask * inner_mask ;
	float angl = (angle(UV-vec2(0.5,0.5),vec2(1,0)) + PI) / (PI * 2.0) ;
	COLOR = circle_mask * (hidden_color * step(progress,1.0-angl) + active_color * step(1.0 - angl,progress)) + (1.0-inner_mask) * fill_color;
	
	
	
}
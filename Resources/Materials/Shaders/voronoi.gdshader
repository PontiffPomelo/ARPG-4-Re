// source : https://www.youtube.com/watch?v=E0BBJMkbskU

shader_type canvas_item;

uniform vec4 color = vec4(1,1,1,1);
uniform vec4 color_max = vec4(1,1,1,1);
uniform vec4 color_min = vec4(1,1,1,1);
uniform float alpha_add = .5;
uniform float alpha_mult = 1.;
uniform float scale = 1.;
uniform float soft = 1.;
uniform float hard = 1.;
uniform float turbulence = 1.;

vec2 RNGV2(vec2 p) {
	vec3 a = fract(p.xyx * vec3(111.11,333.33,444.44));
	a += dot(a, a+33.51);
	return fract(vec2(a.x*a.y,a.y*a.z));
}
float hash(float n) { return fract(sin(n) * 1e4); }
float hash2(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	float u = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), u);
}

float noise2(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash2(i);
	float b = hash2(i + vec2(1.0, 0.0));
	float c = hash2(i + vec2(0.0, 1.0));
	float d = hash2(i + vec2(1.0, 1.0));

	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment()
{
	vec2 uv = UV*scale;
	float m = 0.;
	float t = 121.233 + TIME;
	float minDist = 100.;
	
	uv *= 3.;
	
	vec2 gv = fract(uv*10.)-.5;
	vec2 id = floor(uv*10.);
	vec2 ci;
	
	for(float y=-1.;y<=1.;y++)
	{
		for(float x=-1.;x<=1.;x++)
		{
			vec2 offs = vec2(x,y);
			vec2 n = RNGV2(id+offs);
			vec2 p = offs+sin(n*t) *.5;
			float d = length(gv-p);
			if(d<minDist)
			{
				minDist = d;
			}
		}
	}
	
	float alpha = min((alpha_mult+alpha_add) * 
	(1.-clamp(pow(abs(UV.x-.5)*2.,soft),0,1)) * 
	(1.-clamp(pow(abs(UV.y-.5)*2.,soft),0,1))
	,1);
	
	
	minDist = pow(noise2(vec2(uv.x  + sin(TIME) * 0.1 * turbulence,uv.y*10.)*10.),hard) 
	* pow(noise2(vec2(uv.x,(uv.y  + TIME * 0.02) * 10.)*10. * turbulence),hard) * minDist*2.;
	
	float prev_min_dist = minDist;
	minDist = clamp(pow(minDist,hard),0.,1.);
	
	float comp1 = minDist < 0.0001 ? 1.:0.;
	float comp2 = (minDist <= .15 ? 1.:0.) - comp1;
	float comp3 = 1. - comp2 - comp1;
	
	//vec4 col = vec4(0,0,minDist,1);
	vec4 col = vec4(color * comp2 + color_min * comp1 + color_max*comp3);
	col.a *= alpha;

	float test = noise2(vec2(uv.x  + sin(TIME) * 0.1 * turbulence,uv.y*10.)*10.) 
	* noise2(vec2(uv.x,(uv.y  + TIME * 0.02) * 10.)*10. * turbulence) ;
	
	COLOR = col;//vec4(minDist,minDist,minDist,1.);
	vec4 distorted_background = texture(SCREEN_TEXTURE,vec2(SCREEN_UV.x+(test/100.0),SCREEN_UV.y + (prev_min_dist/20.0)));
	COLOR = col.a * vec4(col.xyz,1.0) + (1.0-col.a) * vec4(distorted_background.xyz,alpha); //
	
}
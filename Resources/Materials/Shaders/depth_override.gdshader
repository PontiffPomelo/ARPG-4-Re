shader_type spatial;
render_mode depth_draw_always,unshaded;

uniform sampler2D colorTexture;
uniform sampler2D depthTexture;
uniform float depthScale : hint_range(0.0,1.0) = 1;
uniform float depthOffset : hint_range(-1,1.0) = 0;

void fragment(){
    vec4 col = texture(colorTexture, UV);
	
    if (col.a <= 0.001) {
        discard;
    }
	
	ALBEDO = col.xyz;
    ALPHA = col.a;

    float depth = texture(depthTexture, UV).r;
    //EMISSION = vec3(depth,depth,depth);
	//gl_FragDepthEXT = depthOffset - depth * depthScale;
	DEPTH = depth;// * depthScale + depthOffset;//depthOffset - depth * depthScale;
	
}
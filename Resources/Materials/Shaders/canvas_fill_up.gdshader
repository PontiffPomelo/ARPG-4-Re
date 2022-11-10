shader_type canvas_item;
render_mode skip_vertex_transform;

uniform vec4  cover_colour : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float cover : hint_range(0.,1.) = 0.0;

void vertex() {
    VERTEX = ( (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0))).xy;
}

void fragment()
{
	COLOR = texture(TEXTURE, UV) * ( (UV.y > (1.-cover) ? 1.0 : 0.0) * cover_colour  + (UV.y <= (1.-cover) ? 1.0 : 0.0)  * vec4(1.0) );
}
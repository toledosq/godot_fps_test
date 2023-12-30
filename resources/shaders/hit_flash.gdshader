shader_type spatial;

uniform bool active = false;
uniform vec4 red : source_color = vec4(1., 0., 0., 1);
uniform vec4 white : source_color = vec4(1.,1.,1.,1);

void fragment() {
	
	if (active == true)
	{
		ALBEDO = red.rgb;
	}
	else
	{
		ALBEDO = white.rgb;
	}
}
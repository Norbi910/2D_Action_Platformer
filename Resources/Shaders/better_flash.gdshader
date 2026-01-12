shader_type canvas_item;

uniform vec4 color_parameter : source_color = vec4(1.000000, 1.000000, 1.000000, 1.000000);
uniform bool enabled;

void fragment() {
	if (enabled) {
		COLOR.rgb = color_parameter.rgb * color_parameter.w + COLOR.rgb * (1.0 -color_parameter.w);
	}
}

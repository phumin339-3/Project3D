shader_type canvas_item;
render_mode unshaded;

uniform float glitch_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float time_scale = 8.0;

float rand(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * time_scale;

	// แบ่งบรรทัดภาพ (scan lines)
	float line = floor(uv.y * 70.0);
	float n = rand(vec2(line, floor(t * 2.0)));

	// jitter แนวนอน (เคลื่อนซ้ายขวา)
	float jitter = (n - 0.5) * 0.25 * glitch_strength;
	vec2 guv = uv + vec2(jitter, 0.0);

	// แยกสี RGB ขยับไปคนละทิศ
	float split = (rand(vec2(line * 1.37, floor(t * 3.0))) - 0.5) * 0.04 * glitch_strength;
	vec4 r = texture(TEXTURE, guv + vec2( split, 0.0));
	vec4 g = texture(TEXTURE, guv + vec2(-split, 0.0));
	vec4 b = texture(TEXTURE, guv);

	// สร้างเส้น scan line
	float scan = (sin(uv.y * 800.0 + t * 10.0) * 0.5 + 0.5) * 0.3 * glitch_strength;

	// base texture
	vec4 base = texture(TEXTURE, uv);
	vec3 glitch_col = vec3(r.r, g.g, b.b) + scan;

	// ผสมสีเดิมกับ glitch
	vec3 mixed = mix(base.rgb, glitch_col, glitch_strength);
	mixed *= tint.rgb;

	float a = base.a * tint.a;
	COLOR = vec4(mixed, a);
}

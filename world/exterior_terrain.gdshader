shader_type canvas_item;
render_mode unshaded;

uniform sampler2D terrain_sheet : source_color, filter_nearest;
uniform float tile_size = 96.0;
uniform vec4 foundation = vec4(996.0, -1756.0, 1720.0, 1208.0);
uniform vec2 entrance = vec2(2716.0, -1152.0);
varying vec2 world_position;

float hash(vec2 point) {
	return fract(sin(dot(point, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 cell = floor(world_position / tile_size);
	vec2 tile_uv = fract(world_position / tile_size);
	// Sample the generated sheet's four quadrants, with stable spatial variants.
	float variant = step(0.55, hash(cell));
	vec2 inset_uv = mix(vec2(0.002), vec2(0.498), tile_uv);
	vec4 grass = texture(terrain_sheet, inset_uv + vec2(variant * 0.5, 0.0));
	vec4 soil = texture(terrain_sheet, inset_uv + vec2(variant * 0.5, 0.5));
	vec2 center = foundation.xy + foundation.zw * 0.5;
	vec2 distance_to_box = abs(world_position - center) - foundation.zw * 0.5;
	float edge_distance = length(max(distance_to_box, vec2(0.0)));
	float grain = hash(floor(world_position / 12.0));
	float bare_edge = 1.0 - smoothstep(24.0, 58.0, edge_distance + grain * 14.0);
	float path_distance = abs(world_position.y - entrance.y);
	float path = (1.0 - smoothstep(44.0, 74.0, path_distance + grain * 16.0)) * step(entrance.x - 16.0, world_position.x);
	float patches = smoothstep(0.88, 0.98, hash(floor(world_position / 160.0))) * 0.15;
	COLOR = mix(grass, soil, max(max(bare_edge, path), patches));
}

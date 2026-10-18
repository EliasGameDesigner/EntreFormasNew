shader_type canvas_item;

uniform bool idle_breathing = false;

void vertex() {
	if (idle_breathing) {
		// Rest atlases have a foot baseline at local y=210. Keep it fixed.
		float upper_body = clamp((210.0 - VERTEX.y) / 427.0, 0.0, 1.0);
		VERTEX.y -= (sin(TIME * 2.2) * 0.5 + 0.5) * 4.0 * upper_body;
	}
}

// Remove faint generated halos while retaining opaque pixel-art silhouettes.
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (pixel.a < 0.7) { discard; }
	COLOR = vec4(pixel.rgb, 1.0);
}

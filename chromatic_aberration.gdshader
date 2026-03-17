shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount = 0.0;

void fragment() {
	// Мы умножаем amount на 5.0, чтобы эффект был заметнее
	vec2 offset = vec2(SCREEN_PIXEL_SIZE.x * amount * 5.0, 0.0);
	
	float r = texture(screen_texture, SCREEN_UV + offset).r;
	float g = texture(screen_texture, SCREEN_UV).g;
	float b = texture(screen_texture, SCREEN_UV - offset).b;
	
	COLOR = vec4(r, g, b, 1.0);
}
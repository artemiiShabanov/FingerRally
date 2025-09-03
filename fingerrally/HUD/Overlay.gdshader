shader_type canvas_item;

	uniform float blur_amount : hint_range(0.0, 10.0) = 2.0;
	uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

	void fragment() {
		vec4 original_color = texture(TEXTURE, UV); // Get the original texture color
		vec4 blurred_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount); // Sample screen texture with LOD for blur

		// You can blend the original and blurred colors as needed
		COLOR = mix(original_color, blurred_color, 0.5); // Example: 50% blend
		// Or simply assign the blurred color: COLOR = blurred_color;
	}
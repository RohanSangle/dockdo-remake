shader_type spatial;

// Screen texture (automatically provided by Godot)
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
//uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_nearest;

// SSR parameters
//uniform float ssr_resolution   : hint_range(0.1, 10.0, 0.1) = 1.0;
//uniform float ssr_max_travel   : hint_range(0.1, 200.0, 0.1) = 40.0;
//uniform float ssr_max_diff     : hint_range(0.1, 10.0, 0.1) = 4.0;
//uniform float ssr_mix_strength : hint_range(0.0, 1.0, 0.01) = 0.9;

// Ocean base color
uniform vec3 albedo : source_color = vec3(0.02, 0.45, 0.8);

// Metallic and roughness
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.9;

// Function to check if a position is within screen boundaries
//bool is_within_screen_boundaries(vec2 position) {
    //return position.x > 0.0 && position.x < 1.0 && position.y > 0.0 && position.y < 1.0;
//}
//
//// Function to get UV coordinates from view space position
//vec2 get_uv_from_view_position(vec3 position_view_space, mat4 proj_m) {
    //vec4 position_clip_space = proj_m * vec4(position_view_space.xyz, 1.0);
    //vec2 position_ndc = position_clip_space.xy / position_clip_space.w;
    //return position_ndc.xy * 0.5 + 0.5;
//}
//
//// Function to get view space position from UV coordinates and depth
//vec3 get_view_position_from_uv(vec2 uv, float depth, mat4 inv_proj_m) {
    //vec4 position_ndc = vec4((uv * 2.0) - 1.0, depth, 1.0);
    //vec4 view_position = inv_proj_m * position_ndc;
    //return view_position.xyz / view_position.w;
//}
//
//// Function to calculate SSR color
//vec3 get_ssr_color(vec3 surface_view_position, vec3 normal_view_space, vec3 view_view_space, mat4 proj_m, mat4 inv_proj_m) {
    //vec3 current_position_view_space = surface_view_position;
    //vec3 view_direction_view_space = view_view_space * -1.0;
    //vec3 reflect_vector_view_space = normalize(reflect(view_direction_view_space.xyz, normal_view_space.xyz));
//
    //vec2 current_screen_position = vec2(0.0);
    //vec3 resulting_color = vec3(-1.0);
//
    //for (float travel = 0.0; resulting_color.x < 0.0 && travel < ssr_max_travel; travel += ssr_resolution) {
        //current_position_view_space += reflect_vector_view_space * ssr_resolution;
        //current_screen_position = get_uv_from_view_position(current_position_view_space, proj_m);
		//
		//current_screen_position.y += 0.01;
		//
        //float depth_texture_probe_raw = texture(DEPTH_TEXTURE, current_screen_position).x;
        //vec3 depth_texture_probe_view_position = get_view_position_from_uv(current_screen_position, depth_texture_probe_raw, inv_proj_m);
//
        //float depth_diff = depth_texture_probe_view_position.z - current_position_view_space.z;
//
        //if (is_within_screen_boundaries(current_screen_position) && depth_diff >= 0.0 && depth_diff < ssr_max_diff) {
            //resulting_color = texture(SCREEN_TEXTURE, current_screen_position.xy).rgb;
        //}
    //}
//
    //return resulting_color;
//}

void fragment() {
    // Get screen depth and surface depth
    //float screen_depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).x;
    //float surface_depth = FRAGCOORD.z;
//
    //// Get view space positions
    //vec3 screen_view_position = get_view_position_from_uv(SCREEN_UV, screen_depth_raw, INV_PROJECTION_MATRIX);
    //vec3 surface_view_position = get_view_position_from_uv(SCREEN_UV, surface_depth, INV_PROJECTION_MATRIX);
//
    //// Calculate SSR color
    //vec3 ssr_color = get_ssr_color(surface_view_position, NORMAL, VIEW, PROJECTION_MATRIX, INV_PROJECTION_MATRIX);
//
	//// If no SSR color is found, use the ocean's base color
    //if (ssr_color.x < 0.0) {
        //ssr_color = albedo;
    //}
    //// Blend SSR color with ocean color
    //vec3 final_color = mix(albedo, ssr_color, ssr_mix_strength);

    // Output the final color
	//ALBEDO = final_color;
    ALBEDO = albedo;
    METALLIC = metallic;
    ROUGHNESS = roughness;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

//shader_type spatial;
//
//// Screen texture (automatically provided by Godot)
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
//uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_nearest;
//
//// Wave parameters
//uniform float wave_scale : hint_range(0.02, 0.15) = 0.063;
//uniform float wave_speed_x : hint_range(-20, 20) = 19.0;
//uniform float wave_speed_y : hint_range(-20, 20) = 9.0;
//uniform float wave_speed_z : hint_range(-20, 20) = -16.0;
//uniform float wave_speed_w : hint_range(-20, 20) = -7.0;
//
//// Reflection and refraction parameters
//uniform float refl_distort : hint_range(0, 1.5) = 0.44;
//uniform float refr_distort : hint_range(0, 1.5) = 0.4;
//uniform vec4 refr_color : source_color = vec4(0.34, 0.85, 0.92, 1);
//
//// Textures
//uniform sampler2D normal_map : hint_normal;
//uniform sampler2D fresnel_map;
//
//void vertex() {
    //// Create vec2 from the first two wave speed components
    //vec2 wave_speed_xy = vec2(wave_speed_x, wave_speed_y);
    //// Wave animation
    //vec2 uv = VERTEX.xz / wave_scale + TIME * wave_speed_xy;
    //VERTEX.y += texture(normal_map, uv).y * wave_scale;
//}
//
//void fragment() {
    //// Get screen UV coordinates
    //vec2 screen_uv = SCREEN_UV;
//
    //// Sample the normal map for wave distortion
    //vec2 distortion = texture(normal_map, screen_uv).xy * vec2(refl_distort, refr_distort);
//
    //// Calculate reflection and refraction UVs
    //vec2 refl_uv = screen_uv + distortion;
    //vec2 refr_uv = screen_uv - distortion;
//
    //// Sample the screen texture for reflections and refractions
    //vec3 refl_color = texture(SCREEN_TEXTURE, refl_uv).rgb;
    //vec3 refracted_color = texture(SCREEN_TEXTURE, refr_uv).rgb * refr_color.rgb;
//
    //// Fresnel effect
    //float fresnel = texture(fresnel_map, screen_uv).r;
    //vec3 final_color = mix(refracted_color, refl_color, fresnel);
//
    //// Output the final color
    //ALBEDO = final_color;
    //METALLIC = 0.5;
    //ROUGHNESS = 0.2;
//}
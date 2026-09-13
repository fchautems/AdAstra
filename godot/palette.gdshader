shader_type spatial;
render_mode cull_disabled;
uniform vec4 original_color : source_color;
uniform float original_roughness = 0.86;
uniform bool threshold = false;
varying vec3 world_position;
uniform vec4 ivory : source_color = vec4(0.910,0.894,0.855,1.0);
uniform vec4 grey : source_color = vec4(0.722,0.710,0.682,1.0);
uniform vec4 graphite : source_color = vec4(0.271,0.286,0.294,1.0);
uniform vec4 accent : source_color = vec4(0.651,0.369,0.302,1.0);
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
    vec3 p = world_position;
    bool corridor = p.x >= 10.0 && p.x <= 47.0 && p.z >= 7.99 && p.z <= 10.36;
    bool cabin = p.x >= 34.0 && p.x <= 43.01 && p.z >= 10.0 && p.z <= 16.01;
    bool inside = (corridor || cabin) && p.y >= -1.02 && p.y <= 2.01;
    ALBEDO = original_color.rgb;
    ROUGHNESS = original_roughness;
    if (inside) {
        ALBEDO = ivory.rgb;
        if (p.y < -0.98) { ALBEDO = graphite.rgb; }
        else if (p.y < -0.65) { ALBEDO = grey.rgb; }
        if (threshold) { ALBEDO = accent.rgb; }
        ROUGHNESS = 0.72;
        // Modest diffuse fill for the blockout, without baked GI.
        EMISSION = ALBEDO * 0.12;
    }
}

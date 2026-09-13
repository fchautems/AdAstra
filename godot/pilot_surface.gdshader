shader_type spatial;
render_mode cull_disabled;
uniform vec4 tint : source_color = vec4(0.8,0.8,0.8,1.0);
uniform float roughness_value = 0.45;
uniform bool floor_surface = false;
varying vec3 world_position;
float grain(vec3 p) { return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453); }
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
 float pixel_size = max(length(dFdx(world_position)),length(dFdy(world_position)));
 float g = mix(0.5,grain(floor(world_position * 380.0)),1.0-smoothstep(0.001,0.006,pixel_size));
 if (!floor_surface) { g = 0.5; }
 ALBEDO = tint.rgb * (0.993 + 0.014*g);
 ROUGHNESS = roughness_value + (g-0.5)*0.055;
 METALLIC = 0.0;
 // Keep painted walls optically smooth; screen-space noise derivatives caused banding.
 if(floor_surface) {
  NORMAL = normalize(NORMAL + vec3(dFdx(g),dFdy(g),0.0)*0.001);
  vec2 p = world_position.xz;
  float seam = min(abs(fract((p.x-18.0)/1.25+0.5)-0.5)*1.25, abs(p.y-9.0));
  float joint = 1.0-smoothstep(0.001,0.003+fwidth(seam),seam);
  ALBEDO = mix(ALBEDO, tint.rgb*0.78,joint);
  ROUGHNESS = mix(ROUGHNESS,0.55,joint);
 }
}

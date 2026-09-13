shader_type spatial;
render_mode cull_disabled;
uniform sampler2D plastic_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D plastic_rough : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rubber_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rubber_rough : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rubber_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool threshold = false;
uniform float hangar_x = 47.0;
varying vec3 pos;
varying vec3 world_normal;
void vertex(){ pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL); }
void fragment(){
 vec3 n=abs(normalize(cross(dFdx(pos),dFdy(pos))));
 vec2 uv = n.y>0.7?pos.xz:(n.z>n.x?pos.xy:pos.zy);
 vec3 tex=texture(plastic_color,uv).rgb;
 ALBEDO=vec3(.84,.83,.79)*mix(vec3(1),tex,.28);
 ROUGHNESS=clamp(texture(plastic_rough,uv).r,.45,.9);
 if(n.y>.7 && pos.y<-.97){
   vec2 floor_uv=pos.xz/.75;
   vec3 rubber=texture(rubber_color,floor_uv).rgb;
   ALBEDO=vec3(.20,.215,.225)*(.8+rubber*.7);
   ROUGHNESS=texture(rubber_rough,floor_uv).r;
   vec2 seam=abs(fract(pos.xz/1.5+.5)-.5)*1.5;
   float line=1.0-smoothstep(.003,.003+max(fwidth(pos.x),fwidth(pos.z)),min(seam.x,seam.y));
   if(pos.x>hangar_x) ALBEDO*=1.0-line*.35;
 }else if(n.y>.7){
   ALBEDO=vec3(.82,.81,.77)*mix(vec3(1),tex,.15);
   vec2 cell=abs(fract(uv/vec2(1.5,1.0)+.5)-.5)*vec2(1.5,1.0);
   float line=1.0-smoothstep(.002,.002+max(fwidth(uv.x),fwidth(uv.y)),min(cell.x,cell.y));
   ALBEDO*=1.0-line*.25;
   ROUGHNESS=.9;
 }else{
   float joint=abs(fract(uv.x/1.5+.5)-.5)*1.5;
   float line=1.0-smoothstep(.002,.002+fwidth(uv.x),joint);
   float belt=1.0-smoothstep(.003,.003+fwidth(pos.y),abs(pos.y-.25));
   ALBEDO*=1.0-max(line,belt)*.3;
   if(pos.y<-.65) {ALBEDO=vec3(.36,.39,.40); METALLIC=.35;}
 }
 if(threshold){ALBEDO=vec3(.37,.13,.08); ROUGHNESS=.8;}
 EMISSION=ALBEDO*.24;
}

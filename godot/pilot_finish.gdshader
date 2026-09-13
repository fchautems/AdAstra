shader_type spatial;
render_mode cull_disabled;
uniform sampler2D base_map : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal_map : hint_normal, filter_linear_mipmap_anisotropic;
uniform sampler2D orm_map : filter_linear_mipmap_anisotropic;
uniform float normal_strength = .28;
void fragment(){
 vec3 c=texture(base_map,UV).rgb;
 vec3 orm=texture(orm_map,UV).rgb;
 float value=dot(c,vec3(.2126,.7152,.0722));
 bool accent=c.r>c.g*1.8 && c.r>c.b*1.8;
 ALBEDO=vec3(.77,.76,.71)*mix(.91,1.03,clamp(value*2.0,0.0,1.0));
 if(accent) ALBEDO=vec3(.27,.20,.14);
 ROUGHNESS=clamp(.48+orm.g*.20,.48,.68);
 METALLIC=accent?.12:0.0;
 AO=orm.r;
 NORMAL_MAP=texture(normal_map,UV).rgb;
 NORMAL_MAP_DEPTH=normal_strength;
}

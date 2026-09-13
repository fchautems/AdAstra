shader_type spatial;
uniform sampler2D atlas : source_color, filter_linear_mipmap;
void fragment(){
 vec3 c=texture(atlas,UV).rgb;
 if(c.r>c.b*1.8 && c.g>c.b*1.2) c=vec3(.37,.14,.09);
 ALBEDO=c;
 ROUGHNESS=.65;
 EMISSION=c*.08;
}

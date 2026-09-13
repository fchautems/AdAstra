"""One correction pass: plan geometry from JSON + actual cabin gaps from SVG.
Blender coordinates are plan X,Y and height Z; GLB exports (X,Z,-Y).
"""
import bpy, bmesh, json, math, hashlib, re
import xml.etree.ElementTree as ET
from mathutils import Vector
from pathlib import Path
ROOT=Path(__file__).resolve().parent
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
top=read('plans/ship-layout-v1.json')
profile=read('plans/side-profile-v5-horizontal-band.json')['profile_geometry']
cfg=read('blockout.json')
extension=cfg['cabin_extension']
stretch=1+extension['added_length_m']/(extension['end_x_m']-extension['start_x_m'])
def X(x):
    lo,hi=extension['start_x_m'],extension['end_x_m']
    return x if x<=lo else (lo+(x-lo)*stretch if x<hi else x+extension['added_length_m'])
floor=profile['inhabited_band']['floor_level_z_m']
roof=floor+cfg['interior']['clear_height_m']
hangar_roof=floor+cfg['interior']['hangar_clear_height_m']
a,b=top['dimensions']['cylinder']['x_start'],top['dimensions']['cylinder']['x_end']
radius=profile['rotating_cylinder']['diameter_m']/2
end=top['dimensions']['overall_length_m']
t=top['walls']['main_structural_wall_thickness_m']
pt=top['walls']['cabin_partition_thickness_m']
ft=cfg['floor_thickness_m']; dh=cfg['interior']['door_height_m']
ns={'s':'http://www.w3.org/2000/svg'}
svg=ET.parse(ROOT/'plans/top-and-side-v3.svg').getroot()
view=svg.find("s:g[@id='topView']",ns)
outline=[tuple(map(float,p.split(','))) for p in view.find("s:polygon[@class='plan']",ns).get('points').split()]
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system='METRIC'
bpy.context.scene.unit_settings.scale_length=1
def material(name,c):
    m=bpy.data.materials.new(name); m.use_nodes=True
    m.diffuse_color=(*c,1); m.use_backface_culling=False
    bs=m.node_tree.nodes.get('Principled BSDF')
    bs.inputs['Base Color'].default_value=(*c,1)
    bs.inputs['Roughness'].default_value=.86
    return m
hull=material('Hull',(.27,.33,.37))
exterior=material('Exterior_Satin',(.42,.49,.53))
exterior.node_tree.nodes.get('Principled BSDF').inputs['Metallic'].default_value=.35
exterior.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=.48
inner=material('Interior_Ivory',(.78,.76,.70))
ceiling=material('Interior_Ceiling',(.38,.42,.44))
deck=material('Deck',(.105,.135,.15))
wallmat=material('Partitions',(.61,.60,.55))
frame=material('Frame',(.13,.20,.23))
guide=material('Circulation',(.17,.26,.29))
glass=material('Glass',(.2,.4,.5))
glass.node_tree.nodes.get('Principled BSDF').inputs['Alpha'].default_value=.12
glass.surface_render_method='DITHERED'
lightmat=material('Diffuser',(.7,.8,.82))
bs=lightmat.node_tree.nodes.get('Principled BSDF')
bs.inputs['Emission Color'].default_value=(.66,.81,.87,1)
bs.inputs['Emission Strength'].default_value=1.2
def mesh(name,v,f,mat):
    data=bpy.data.meshes.new(name); data.from_pydata([(X(x),y,z) for x,y,z in v],[],f); data.update()
    bm=bmesh.new(); bm.from_mesh(data)
    bmesh.ops.triangulate(bm,faces=list(bm.faces))
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(data); bm.free()
    ob=bpy.data.objects.new(name,data); bpy.context.collection.objects.link(ob)
    data.materials.append(mat)
    return ob
def slab(name,poly,z0,z1,mat):
    n=len(poly)
    return mesh(name,[(x,y,z) for z in (z0,z1) for x,y in poly],
        [tuple(reversed(range(n))),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)],mat)
def box(name,x0,x1,y0,y1,z0,z1,mat=wallmat):
    return slab(name,[(x0,y0),(x1,y0),(x1,y1),(x0,y1)],z0,z1,mat)
def wall(name,p,q,z0,z1,mat=wallmat,thickness=t):
    dx,dy=q[0]-p[0],q[1]-p[1]; le=math.hypot(dx,dy)
    ox,oy=dy*thickness/le,-dx*thickness/le
    ob=slab(name,[p,(p[0]+ox,p[1]+oy),(q[0]+ox,q[1]+oy),q],z0,z1,mat)
    ob['interior_line']=[X(p[0]),p[1],X(q[0]),q[1]]
    return ob
def beam(name,p,q,r=.055,mat=frame):
    p=(X(p[0]),p[1],p[2]); q=(X(q[0]),q[1],q[2])
    delta=Vector(q)-Vector(p)
    bpy.ops.mesh.primitive_cylinder_add(vertices=8,radius=r,depth=delta.length,location=(Vector(p)+Vector(q))/2)
    ob=bpy.context.object; ob.name=name
    ob.rotation_euler=delta.to_track_quat('Z','Y').to_euler(); ob.data.materials.append(mat)

def shell(ob, thickness=t, outward=None):
    # Weld patch boundaries before solidifying: a real continuous inner skin
    # and window reveals, rather than independently thickened triangles.
    bm=bmesh.new(); bm.from_mesh(ob.data)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0001)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    if outward is not None:
        for face in bm.faces:
            if face.normal.dot(Vector(outward))<0: face.normal_flip()
    bm.to_mesh(ob.data); bm.free()
    ob.data.materials.clear(); ob.data.materials.append(exterior); ob.data.materials.append(inner)
    mod=ob.modifiers.new('Structural thickness','SOLIDIFY')
    mod.thickness=thickness; mod.offset=-1; mod.material_offset=1; mod.material_offset_rim=1
    bpy.context.view_layer.objects.active=ob
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return ob
lights=[]; labels=[]; routes=[]; audit={}; reference=[]
def lamp(x,y,length=2,z=None):
    z=roof if z is None else z
    box('Guide_Light',x-length/2,x+length/2,y-.08,y+.08,z-.055,z-.035,lightmat)
    lights.append([X(x),z-.35,-y])
# Exact footprint, floor clipped only where it meets the lower pointed hull.
nose_floor=a*abs(floor)/abs(profile['cockpit']['z_min_m'])
floor_outline=[(nose_floor,-nose_floor)]+outline[1:]+[(nose_floor,nose_floor)]
slab('Continuous_deck',floor_outline,floor-ft,floor,deck)
# Source body silhouette; no interior partitions in the cockpit.
body=[(10,-10),(16,-16),(39,-16),(39,-10),(43,-10),(43,10),(39,10),(39,16),(16,16),(10,10)]
slab('Living_roof',body,roof,roof+t,hull)
for i,p in enumerate(body):
    if i not in (4,9): wall('Hull_body',p,body[(i+1)%len(body)],floor,roof)
hang=[(43,-10),(49,-14),(58,-14),(58,14),(49,14),(43,10)]
slab('Hangar_roof',hang,hangar_roof,hangar_roof+t,hull)
for i in range(len(hang)-1): wall('Hull_hangar',hang[i],hang[i+1],floor,hangar_roof)
# Close the height transition above every passage into the hangar.
# The detached lower slab is removed: the continuous deck is the lower skin.
# Replace the blunt hanging header by a ceiling transition above the passage.
v=[]
for i in range(25):
    u=i/24
    z=roof+(hangar_roof-roof)*(u*u*(3-2*u))
    v.extend([(43+6*u,-10,z),(43+6*u,10,z)])
header=mesh('Hangar_front_upper_seal',v,[(2*i,2*i+1,2*i+3,2*i+2) for i in range(24)],inner)
mod=header.modifiers.new('Ceiling thickness','SOLIDIFY'); mod.thickness=.15
bpy.context.view_layer.objects.active=header; bpy.ops.object.modifier_apply(modifier=mod.name)
# Only seal the exposed wings; the cylinder already closes the central area.
for side in [-1,1]:
    for upper in [True,False]:
        z0=4 if upper else -4
        z1=roof+t if upper else floor-ft
        shell(mesh('Cockpit_transition',[(10,side*6.8,z0),(10,side*10,z0),(12,side*12,z1),(12,side*6.8,z1)],[(0,1,2,3)],hull),outward=(0,0,1 if upper else -1))
        shell(mesh('Cockpit_transition_edge',[(10,side*10,z0),(12,side*12,z1),(10,side*10,z1)],[(0,1,2)],hull),outward=(-1,side,0))
# Smaller windows are cut into the actual sloping prow facets. Opaque borders,
# opaque nose tip and separate aft windows retain a pointed structural shell.
nose=(0,0,0)
def ring(x): return [(x,-x,-.4*x),(x,x,-.4*x),(x,x,.4*x),(x,-x,.4*x)]
back=ring(a)
shell(mesh('Cockpit_bottom',[nose,back[0],back[1]],[(0,1,2)],hull),outward=(-.4,0,-1))
def prow_point(face,x,u):
    return (x,(-1+2*u)*x,.4*x) if face==2 else (x,x if face==1 else -x,(-.4+.8*u)*x)
for face in [1,2,3]:
    buckets={False:([],[]),True:([],[])}
    xx=[0,1.3,4.6,6.6,8.4,10]
    uu=[0,.12,.35,.45,.65,.88,.9,1]
    for x0,x1 in zip(xx,xx[1:]):
        for u0,u1 in zip(uu,uu[1:]):
            xm,um=(x0+x1)/2,(u0+u1)/2
            glazing=(1.3<xm<4.6 and ((.12<um<.88) if face==2 else (.45<um<.9))) or (6.6<xm<8.4 and ((.35<um<.65) if face==2 else (.45<um<.65)))
            verts,faces=buckets[glazing]
            points=([nose,prow_point(face,x1,u0),prow_point(face,x1,u1)] if x0==0 else [prow_point(face,x0,u0),prow_point(face,x1,u0),prow_point(face,x1,u1),prow_point(face,x0,u1)])
            start=len(verts); verts.extend(points); faces.append(tuple(range(start,start+len(points))))
    for glazing,(verts,faces) in buckets.items():
        ob=mesh(('Glass_' if glazing else 'Cockpit_skin_')+str(face),verts,faces,glass if glazing else hull)
        if glazing:
            # Set glass inside the 35 cm reveal, with its own 25 mm thickness.
            normal=Vector((-.4,0,1) if face==2 else (-1,1 if face==1 else -1,0)).normalized()
            bm=bmesh.new(); bm.from_mesh(ob.data)
            bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0001)
            bmesh.ops.dissolve_limit(bm,angle_limit=.001,verts=list(bm.verts),edges=list(bm.edges))
            bm.to_mesh(ob.data); bm.free()
            for vertex in ob.data.vertices: vertex.co-=normal*(t*.55)
            mod=ob.modifiers.new('Glazing thickness','SOLIDIFY'); mod.thickness=.025
            bpy.context.view_layer.objects.active=ob; bpy.ops.object.modifier_apply(modifier=mod.name)
        else:
            # Enforce outward orientation on the disconnected open patches.
            normal=Vector((-.4,0,1) if face==2 else (-1,1 if face==1 else -1,0))
            bm=bmesh.new(); bm.from_mesh(ob.data)
            for f in bm.faces:
                if f.normal.dot(normal)<0: f.normal_flip()
            bm.to_mesh(ob.data); bm.free()
            shell(ob,outward=normal)
lamp(8,0,2,z=3.05)
# Cylinder is restored to the specified constant diameter and station limits.
# Its two plan rectangles remain reserved volumes, not invented rooms.
for sign in [-1,1]:
    y0,y1=sorted([sign*1,sign*8])
    box('Cylinder_plan_volume',a,b,y0,y1,floor,roof,hull)
for name,angles in [('upper',(math.asin(roof/radius),math.pi-math.asin(roof/radius))),('lower',(math.pi-math.asin(floor/radius),2*math.pi+math.asin(floor/radius)))]:
    n=max(97,cfg['cylinder_segments']//2+1)
    arc=[(radius*math.cos(angles[0]+(angles[1]-angles[0])*i/(n-1)),radius*math.sin(angles[0]+(angles[1]-angles[0])*i/(n-1))) for i in range(n)]
    ob=mesh('Cylinder_'+name,[(x,y,z) for x in [a,b] for y,z in arc],
         [(i,i+1,i+1+n,i+n) for i in range(n-1)]+[tuple(reversed(range(n))),tuple(range(n,2*n))],hull)
    ob.data.materials.clear(); ob.data.materials.append(exterior)
    for polygon in ob.data.polygons:
        polygon.use_smooth=abs(polygon.normal.x)<.5
# Cabin-front segments and actual 1.2m gaps are read verbatim from reference SVG.
openings={}; cabin_polygons=[]
for s,group,key in [(-1,'upper-structure','upper_side'),(1,'lower-structure','lower_side')]:
    segments=[(float(el.get('x1')),float(el.get('x2'))) for el in view.find("s:g[@id='"+group+"']",ns).findall('s:line',ns)]
    gaps=[(segments[i][1],segments[i+1][0]) for i in range(len(segments)-1)]
    openings[key]=gaps
    for lo,hi in segments:
        yy=sorted([s*10,s*(10+t)])
        box('Cabin_front',lo,hi,*yy,floor,roof)
    for i,(lo,hi) in enumerate(gaps):
        yy=sorted([s*10,s*(10+t)])
        box('Cabin_lintel',lo,hi,*yy,floor+dh,roof)
        # Source opening remains unobstructed; no overlapping decorative frame.
        yy=sorted([s*9.8,s*10.4])
        box('Guide_Threshold',lo,hi,*yy,floor+.004,floor+.008,guide)
        c=top['cabins'][key][i]; center=(lo+hi)/2
        labels.append({'text':c['id'],'position':[X(center),floor+2.70,-s*9.975],'yaw':0 if s>0 else 180,'color':'blue'})
        # Preserve the leading tapered portion of the first cabin; no x=16 wall.
        poly=([(10,s*10),(16,s*16),(c['x_end'],s*16),(c['x_end'],s*10)] if i==0 else
              [(c['x_start'],s*10),(c['x_start'],s*16),(c['x_end'],s*16),(c['x_end'],s*10)])
        # Actual clear floor area: outer walls sit outside the source outline;
        # front wall and half-thickness cabin partitions consume usable space.
        rear_x=X(c['x_end'])-(pt/2 if i<2 else 0)
        front_y=10+t
        usable=([(front_y,s*front_y),(16,s*16),(rear_x,s*16),(rear_x,s*front_y)] if i==0 else [(X(c['x_start'])+pt/2,s*front_y),(X(c['x_start'])+pt/2,s*16),(rear_x,s*16),(rear_x,s*front_y)])
        area=abs(sum(p[0]*q[1]-q[0]*p[1] for p,q in zip(usable,usable[1:]+usable[:1])))/2
        cabin_polygons.append({'id':c['id'],'polygon':[(X(x),y) for x,y in poly],'opening':[X(lo),X(hi)],'usable_area_m2':round(area,2),'usable_polygon':usable})
        lamp(center,s*13,3)
    for x in top['cabins']['partition_centerlines']['upper_x' if s<0 else 'lower_x']:
        yy=sorted([s*(10+t),s*16])
        box('Cabin_partition',x-pt/2,x+pt/2,*yy,floor,roof)
    # Exact diagonal return into hangar from the plan; no extra vestibule.
    p,q=(43,s*8),(49,s*12)
    wall('Diagonal_source',p,q,floor,hangar_roof,thickness=-t if s<0 else t)
    box('Guide_Lateral',10,43,*sorted([s*8,s*10]),floor+.002,floor+.004,guide)
    for x in [12,18,24,30,36,41]: lamp(x,s*9,1.6)
    lamp(46,s*11,1.6)
box('Guide_Central',10,43,-1,1,floor+.002,floor+.004,guide)
for x in [12,18,24,30,36,41]: lamp(x,0,1.6)
for x in [48,54]:
    for y in [-7,0,7]: lamp(x,y,3,z=hangar_roof)
# Routes remain strictly on the three source circulation bands, entering cabins
# through the SVG gaps; side bands are joined via cockpit and hangar only.
routes=[[8,0,0],[8,0,7],[9.6,0,9],[12,0,9]]
for key,z in [('upper_side',9),('lower_side',-9)]:
    if key=='lower_side': routes += [[41,0,9],[46,0,11],[50,0,13],[53,0,0],[50,0,-13],[46,0,-11],[41,0,-9]]
    for lo,hi in openings[key]:
        x=(lo+hi)/2
        routes += [[x,0,z],[x,0,13 if z>0 else -13],[x,0,z]]
routes += [[12,0,-9],[9.6,0,-9],[8,0,-7],[8,0,0],[20,0,0],[42,0,0],[53,0,0],[7,0,0]]
# Reference overlay uses the independent SVG, not the generated meshes.
for el in view.iter():
    typ=el.tag.split('}')[-1]
    if el.get('class') not in ('plan','wall'): continue
    if typ=='line':
        reference.append([[float(el.get('x1')),float(el.get('y1'))],[float(el.get('x2')),float(el.get('y2'))]])
    elif typ in ('rect','polygon','path'):
        if typ=='rect':
            x,y,w,h=[float(el.get(k)) for k in ('x','y','width','height')]
            points=[(x,y),(x+w,y),(x+w,y+h),(x,y+h),(x,y)]
        elif typ=='polygon':
            points=[tuple(map(float,v.split(','))) for v in el.get('points').split()]; points.append(points[0])
        else:
            nums=list(map(float,re.findall(r'-?\d+(?:\.\d+)?',el.get('d'))))
            points=list(zip(nums[0::2],nums[1::2]))
        reference += [[p,q] for p,q in zip(points,points[1:])]
reference=[[[X(x),y] for x,y in segment] for segment in reference]
audit={'reference':'source plan stretched only along X, authorized 4m extension','length_m':X(end),'cabin_count':len(cabin_polygons),
 'cabins':cabin_polygons,'circulation_bands':top['validated_constraints'],
 'no_new_room_functions':True,'furniture_count':0,'cylinder_station_range':[X(a),X(b)],
 'upper_partition_x':[X(x) for x in top['cabins']['partition_centerlines']['upper_x']],
 'lower_partition_x':[X(x) for x in top['cabins']['partition_centerlines']['lower_x']],
 'height_only_retained_override_m':roof-floor}
assert len(cabin_polygons)==top['cabins']['count_total']==6
assert all(abs(hi-lo-1.2)<1e-6 for gaps in openings.values() for lo,hi in gaps)
out=ROOT/'godot'/'assets'; out.mkdir(parents=True,exist_ok=True)
# Continuous exterior loft. Existing structural meshes remain the source of
# interior surfaces and collisions; their exterior material is hidden in Godot.
# Stations are in source-plan metres and pass through X exactly once.
def smoothstep(lo,hi,x):
    u=max(0,min(1,(x-lo)/(hi-lo)))
    return u*u*(3-2*u)

def blendmax(v,w,k=1.25):
    h=max(k-abs(v-w),0)/k
    return max(v,w)+h*h*k*.25

def skin_width(x):
    if x<=16: return min(16+t,x+t*math.sqrt(2)*smoothstep(8.6,12,x))
    if x<=39: return 16+t
    if x<49: return 16+t-2*smoothstep(39,49,x)
    return 14+t

def section(x):
    front=smoothstep(8.6,14,x)
    rear=smoothstep(b,49,x)
    base=(.4*x if x<10 else 4+(roof+t-4)*smoothstep(10,16,x))
    base=base+(hangar_roof+t-base)*smoothstep(39,43,x)
    low=(-.4*x if x<10 else -4+(floor-ft+4)*smoothstep(10,16,x))
    low=low+(floor-ft-low)*rear
    width=skin_width(x)
    edge=.16*smoothstep(8.6,12,x)
    upper=[]; lower=[]
    for i in range(161):
        y=width*(-1+2*i/160)
        circ=math.sqrt(max(0,radius*radius-y*y))
        crest=blendmax(base,circ)
        trough=-blendmax(-low,circ)
        z=base+(crest-base)*front*(1-rear)
        zb=low+(trough-low)*front*(1-rear)
        if edge>0 and abs(y)>width-edge:
            cut=edge-math.sqrt(max(0,edge*edge-(abs(y)-width+edge)**2))
            z-=cut; zb+=cut
        upper.append((x,y,z)); lower.append((x,y,zb))
    return upper+list(reversed(lower))

stations=[8.6]+[8.6+(end+t-8.6)*i/220 for i in range(1,221)]
verts=[v for x in stations for v in section(x)]
stride=322
faces=[]
for j in range(len(stations)-1):
    for i in range(stride):
        n=(i+1)%stride
        faces.append((j*stride+i,j*stride+n,(j+1)*stride+n,(j+1)*stride+i))
faces.append(tuple(range((len(stations)-1)*stride,len(verts))))
outer=mesh('Guide_ExteriorContinuous',verts,faces,exterior)
for p in outer.data.polygons: p.use_smooth=abs(p.normal.x)<.98
# Structural shell thickness, without changes to the existing FPS collision set.
mod=outer.modifiers.new('Outer skin thickness','SOLIDIFY'); mod.thickness=.12; mod.offset=-1
bpy.context.view_layer.objects.active=outer; bpy.ops.object.modifier_apply(modifier=mod.name)
# Keep inside/outside assignments per face in the GLB. No global metal override.
for ob in list(bpy.context.scene.objects):
    if ob.type!='MESH': continue
    name=ob.name
    if name.startswith(('Hull_body','Hull_hangar')):
        ob.data.materials.clear(); ob.data.materials.append(inner); ob.data.materials.append(exterior)
        x0,y0,x1,y1=ob['interior_line']
        for p in ob.data.polygons:
            on_inner=all(abs((ob.data.vertices[i].co.x-x0)*(y1-y0)-(ob.data.vertices[i].co.y-y0)*(x1-x0))<.00001 for i in p.vertices)
            p.material_index=0 if on_inner else 1
    elif name in ('Living_roof','Hangar_roof','Continuous_deck'):
        ob.data.materials.clear(); ob.data.materials.append(ceiling if 'roof' in name else deck); ob.data.materials.append(exterior)
        for p in ob.data.polygons:
            p.material_index=int(p.normal.z>-.5 if 'roof' in name else p.normal.z<.5)
    elif name.startswith('Hangar_front_upper_seal'):
        ob.data.materials.clear(); ob.data.materials.append(inner)
        for p in ob.data.polygons: p.material_index=0
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'blockout.blend'))
bpy.ops.export_scene.gltf(filepath=str(out/'adastra.glb'),export_format='GLB',export_yup=True,export_apply=True,export_animations=False)
params={'length':X(end),'longitudinal_scale':stretch,'width':32,'floor':floor,'roof':roof,'hangar_roof':hangar_roof,'lights':lights,'labels':labels,
'routes':[[X(x),y,z] for x,y,z in routes],'cylinder_start':X(a),'cylinder_end':X(b),'spawn':[7,floor+.05,0],'config':cfg,'reference_lines':reference,'cabins':cabin_polygons,
'source_hashes':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((ROOT/'plans').glob('*'))}}
(out/'parameters.json').write_text(json.dumps(params,indent=2),encoding='utf-8')
(ROOT/'plan-conformity.json').write_text(json.dumps(audit,indent=2),encoding='utf-8')
print('PLAN_BLOCKOUT_03_EXPORTED')

"""Original, bitmap-free modular kit. Coordinates below are Godot metres.
Run with portable Blender; the existing ship/blockout is never edited here.
"""
import bpy, math
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parent
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
bpy.context.scene.unit_settings.system='METRIC'

def mat(name,color,rough=.5,metal=0,emission=0):
    m=bpy.data.materials.new(name); m.use_nodes=True
    s=m.node_tree.nodes.get('Principled BSDF')
    s.inputs['Base Color'].default_value=(*color,1)
    s.inputs['Roughness'].default_value=rough
    s.inputs['Metallic'].default_value=metal
    if emission:
        s.inputs['Emission Color'].default_value=(*color,1)
        s.inputs['Emission Strength'].default_value=emission
    return m
ivory=mat('Kit_Ivory',(.72,.70,.65),.48)
grey=mat('Kit_Satin',(.20,.23,.25),.4,.25)
dark=mat('Kit_Graphite',(.025,.033,.045),.48,.15)
red=mat('Kit_DeepRed',(.32,.012,.023),.32,.12)
floor=mat('Kit_PearlFloor',(.57,.59,.58),.3,.12)
light=mat('Kit_Diffuser',(.85,.93,1),.55,0,1.4)
screen=mat('Kit_Display',(.018,.075,.105),.4,0,.6)
indicator=mat('Kit_Indicators',(.18,.52,.65),.6,0,.7)
parent=None
def group(name):
    global parent
    parent=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(parent)
def xyz(v): return (v[0],-v[2],v[1])
def cube(name,at,size,material,bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(at))
    ob=bpy.context.object; ob.name=name; ob.parent=parent
    ob.scale=(size[0],size[2],size[1]); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    ob.data.materials.append(material)
    if bevel:
        mod=ob.modifiers.new('Soft machined edges','BEVEL'); mod.width=bevel; mod.segments=4
        bpy.ops.object.modifier_apply(modifier=mod.name)
        mod=ob.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return ob
def pathmesh(name,points,width,depth,material):
    # Sweep a rectangular solid along a rounded arch, all in the XY plane.
    v=[]; faces=[]
    for i,p in enumerate(points):
        before=Vector(points[max(0,i-1)]); after=Vector(points[min(len(points)-1,i+1)])
        tangent=(after-before).normalized(); n=Vector((-tangent.y,tangent.x,0))
        for sign,z in [(-1,-depth/2),(1,-depth/2),(1,depth/2),(-1,depth/2)]:
            q=Vector(p)+n*(sign*width/2); q.z+=z; v.append(xyz(q))
    for i in range(len(points)-1):
        for j in range(4): faces.append((4*i+j,4*i+(j+1)%4,4*(i+1)+(j+1)%4,4*(i+1)+j))
    faces.extend([(3,2,1,0),tuple(range(len(v)-4,len(v)))])
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(v,[],faces); mesh.update()
    ob=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(ob); ob.parent=parent; mesh.materials.append(material)
    mod=ob.modifiers.new('Edge softness','BEVEL'); mod.width=.012; mod.segments=3
    bpy.context.view_layer.objects.active=ob; bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=ob.modifiers.new('Normals','WEIGHTED_NORMAL'); bpy.ops.object.modifier_apply(modifier=mod.name)
def archpath(half=.96,height=2.87,r=.24):
    pts=[(-half,.035,0),(-half,.8,0),(-half,height-r,0)]
    for i in range(13):
        a=math.pi-i*math.pi/24; pts.append((-half+r+r*math.cos(a),height-r+r*math.sin(a),0))
    for i in range(13):
        a=math.pi/2-i*math.pi/24; pts.append((half-r+r*math.cos(a),height-r+r*math.sin(a),0))
    pts.extend([(half,.8,0),(half,.035,0)])
    return pts

group('CorridorArch')
pathmesh('RoundedStructure',archpath(),.17,.20,ivory)
for z in [-.105,.105]:
    pathmesh('IntegratedLight',[(x,y,z) for x,y,_ in archpath(.935,2.835,.24)],.022,.012,light)
for x in [-.96,.96]: cube('ArchFoot',(x,.09,0),(.19,.18,.24),grey,.025)

group('FloorTile')
cube('Panel',(0,.009,0),(2.494,.018,1.99),floor,.006)
for z in [-.875,.875]: cube('EdgeBand',(0,.020,z),(2.49,.004,.18),grey)
for x in [-1.075,1.075]:
    cube('RedSeam',(x,.023,0),(.014,.004,1.44),red)
    for s in [-1,1]:
        ob=cube('RedReturn',(x+.065*s,.023,s*.79),(.19,.004,.013),red)
        ob.rotation_euler.z=s*math.pi/4

group('CeilingBay')
cube('CeilingPanel',(0,0,0),(2.48,.035,1.80),ivory,.014)
for s in [-1,1]:
    cube('RedInset',(0,-.033,s*.62),(1.90,.022,.25),red,.015)
    cube('DarkVent',(0,-.047,s*.63),(1.40,.012,.12),dark,.008)
cube('VisibleDiffuser',(0,-.04,0),(1.45,.026,.12),light,.01)

group('DoorLeaf')
cube('RedLeaf',(0,1.21,0),(.50,2.42,.10),red,.035)
cube('BlackInsert',(.21,1.78,-.057),(.062,1.10,.02),dark,.025)
cube('BlackInsertBack',(.21,1.78,.057),(.062,1.10,.02),dark,.025)

group('DoorLight')
cube('LightMount',(0,1.65,0),(.065,1.55,.055),ivory,.025)
cube('VerticalDiffuser',(0,1.65,-.031),(.025,1.42,.014),light,.011)

group('Console')
cube('ConsoleBase',(0,.39,.08),(1.42,.78,.48),dark,.10)
cube('RedRim',(0,.87,0),(1.70,.10,.72),red,.035)
ob=cube('ControlSurface',(0,.91,-.04),(1.53,.07,.56),dark,.025); ob.rotation_euler.x=math.radians(12)
cube('Display',(0,1.15,.24),(1.46,.44,.075),dark,.04)
cube('Screen',(0,1.15,.194),(1.30,.30,.013),screen,.018)
for i in range(5):
    cube('Readout',(-.49+i*.235,1.15,.181),(.11,.015+.018*(i%3),.006),indicator,.003)
cube('ConsoleLight',(0,.83,-.367),(1.38,.018,.012),light,.005)

group('CommandPlatform')
cube('LowDais',(0,.06,0),(2.15,.12,1.50),dark,.055)
for z in [-.70,.70]: cube('RedOutline',(0,.126,z),(1.99,.01,.022),red,.008)

group('BridgeRing')
for z in [-1.55,1.55]: cube('CeilingMount',(0,.65,z),(.035,1.3,.035),grey,.012)
for radius,thick,material in [(1.68,.065,dark),(1.60,.019,light),(1.72,.019,red)]:
    bpy.ops.mesh.primitive_torus_add(major_radius=radius,minor_radius=thick,major_segments=80,minor_segments=8)
    ob=bpy.context.object; ob.name='CircularLight'; ob.parent=parent; ob.data.materials.append(material)
    for p in ob.data.polygons: p.use_smooth=True

bpy.ops.export_scene.gltf(filepath=str(ROOT/'godot/assets/identity_kit.glb'),export_format='GLB',export_yup=True,export_apply=True,export_animations=False)
print('IDENTITY_KIT_EXPORTED: 8 reusable modules, procedural materials only')

import bpy,bmesh
from pathlib import Path
r=Path(__file__).resolve().parent/'godot/assets/pilot'
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(r/'quaternius/Door_Frame_A.gltf'))
for ob in bpy.context.scene.objects:
 if ob.type!='MESH':continue
 bpy.context.view_layer.objects.active=ob
 bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
 bm=bmesh.new();bm.from_mesh(ob.data)
 remove=[]
 for f in bm.faces:
  xs=[v.co.x for v in f.verts];zs=[v.co.z for v in f.verts]
  if min(xs)<0<max(xs) and max(zs)<.5:remove.append(f)
 bmesh.ops.delete(bm,geom=remove,context='FACES')
 for v in bm.verts:
  x,y,z=v.co
  v.co.x=(1 if x>0 else -1)*(.63+(abs(x)-1.137)*.20) if abs(x)>=1.137 else x*.63/1.137
  v.co.y=y*.12
  v.co.z=max(0,z)*2.50/3.834 if z<=3.834 else 2.50+(z-3.834)*.16
 bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(ob.data);bm.free()
bpy.ops.export_scene.gltf(filepath=str(r/'frame.glb'),export_format='GLB',export_apply=True)

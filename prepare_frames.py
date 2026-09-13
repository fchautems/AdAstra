"""Adapt CC0 Kenney frame to existing openings; no change to blockout."""
import bpy,bmesh
from pathlib import Path
root=Path(__file__).resolve().parent
for name,width in [('frame_standard',1.2),('frame_stretched',1.2*18/14)]:
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    bpy.ops.import_scene.gltf(filepath=str(root/'godot/assets/station/door-single.glb'))
    for ob in list(bpy.context.scene.objects):
        if ob.type!='MESH':continue
        bpy.context.view_layer.objects.active=ob
        bpy.ops.object.transform_apply(location=False,rotation=True,scale=True)
        bm=bmesh.new();bm.from_mesh(ob.data)
        remove=[]
        for face in bm.faces:
            xs=[v.co.x for v in face.verts]; zs=[v.co.z for v in face.verts]
            if min(xs)<0<max(xs) and min(zs)<.599:remove.append(face)
        bmesh.ops.delete(bm,geom=remove,context='FACES')
        for v in bm.verts:
            x,y,z=v.co
            v.co.x=(1 if x>0 else -1)*(width/2+.025+(abs(x)-.1)*1.7)
            v.co.y=y*1.2
            v.co.z=0 if z<=.1 else (z-.1)/.5*2.48 if z<=.6 else 2.48+(z-.6)*1.7
        bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.0001)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(ob.data);bm.free()
        mod=ob.modifiers.new('Soft edges','BEVEL');mod.width=.025;mod.segments=3
        ob.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    bpy.ops.export_scene.gltf(filepath=str(root/'godot/assets/station'/f'{name}.glb'),export_format='GLB',export_apply=True)

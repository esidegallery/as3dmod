package com.as3dmod.plugins.away3d4_1 {
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.ISubGeometry;
	import away3d.core.base.SubGeometry;
	import com.as3dmod.core.FaceProxy;
	import com.as3dmod.core.MeshProxy;
	import com.as3dmod.core.VertexProxy;
	
	import away3d.core.base.data.Vertex;	
	import away3d.entities.Mesh;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary
	
	/** Меш движка Away3D 4.1. */
	public class Away3d4Mesh extends MeshProxy {
		
		private var awm:Mesh;
		private var v:Vector.<Number>;
		
		/** Создает новый экземпляр класса Away3d4Mesh. */
		public function Away3d4Mesh(){}
		
		/** @inheritDoc */
		override public function setMesh(mesh:*):void {
			awm = mesh as Mesh;
			
			if (!awm.geometry || !awm.geometry.subGeometries.length) throw "No geometry in the mesh!";
			
			var i:int;
			var sg:Vector.<ISubGeometry> = awm.geometry.subGeometries;
			var sl:int = sg.length;
			for (var n:int = 0;  n < sl; n++) {
				var vs:Vector.<Number> = sg[n].vertexData;
				var vc:int = vs.length;
				var vi:Vector.<uint> = sg[n].indexData;
				var vt:int = vi.length;
				var strideLength:uint = sg[n].vertexStride;
				
				for (i = 0; i < vc; i += strideLength) {
					var nv:Away3d4Vertex = new Away3d4Vertex();
					nv.setVertex(new Vertex(vs[i], vs[i + 1], vs[i + 2]));
					vertices.push(nv);
				}
				
				for (i = 0; i < vt; i+=3) {
					var nt:FaceProxy = new FaceProxy();
					nt.addVertex(vertices[vi[ i ]]);
					nt.addVertex(vertices[vi[i+1]]);
					nt.addVertex(vertices[vi[i+2]]);
					faces.push(nt);
				}
			}
		}
		
		/** @inheritDoc */
		override public function updateVertices():void {
			v ||= new Vector.<Number>();
			
			v.length = 0;
			
			var sg:Vector.<ISubGeometry> = awm.geometry.subGeometries;
			var vs:Vector.<VertexProxy> = getVertices();
			var vc:int = vs.length - 1;
			var vn:int = 0;
			var vl:int = sg[vn].vertexData.length;
			var vv:Vector.<Number>;
			
			for (var i :int = 0; i <= vc; i++) {
				if (sg[vn] is SubGeometry) {
					v.push(vs[i].x, vs[i].y, vs[i].z);
					if (v.length == vl && i != vc) {
						SubGeometry(sg[vn++]).updateVertexData(v.splice(0, v.length));
						vl = sg[vn].vertexData.length;
					}
				} else {
					if (!vv) vv = CompactSubGeometry(sg[vn]).vertexData;
					vv[i * 13] = vs[i].x;
					vv[i * 13 + 1] = vs[i].y;
					vv[i * 13 + 2] = vs[i].z;
				}
			}
			
			if (awm.geometry.subGeometries[vn] is SubGeometry)
				SubGeometry(awm.geometry.subGeometries[vn]).updateVertexData(v);
			else
				CompactSubGeometry(awm.geometry.subGeometries[vn]).updateData(vv);
		}
		
		/** @inheritDoc */
		override public function updateMeshPosition(p:Vector3D):void {
			awm.x += p.x;
			awm.y += p.y;
			awm.z += p.z;
		}
	}
}
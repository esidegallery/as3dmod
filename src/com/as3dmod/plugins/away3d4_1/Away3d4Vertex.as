package com.as3dmod.plugins.away3d4_1 {
	import com.as3dmod.core.VertexProxy;
	
	import away3d.core.base.data.Vertex;	
	
	/** Вершина меша движка Away3D 4.1. */
	public class Away3d4Vertex extends VertexProxy {
		
		private var vx:Vertex;
		
		/** Создает новый экземпляр класса Away3d4Vertex. */
		public function Away3d4Vertex(){}
		
		/** @inheritDoc */
		override public function setVertex(vertex:*):void {
			vx = vertex as Vertex;
			ox = vx.x;
			oy = vx.y;
			oz = vx.z;
		}
		
		/** @inheritDoc */
		override public function get x():Number { return vx.x; }
		/** @inheritDoc */
		override public function get y():Number { return vx.y; }
		/** @inheritDoc */
		override public function get z():Number { return vx.z; }
		/** @inheritDoc */
		override public function set x(v:Number):void { vx.x = v; }
		/** @inheritDoc */
		override public function set y(v:Number):void { vx.y = v; }
		/** @inheritDoc */
		override public function set z(v:Number):void { vx.z = v; }
	}
}
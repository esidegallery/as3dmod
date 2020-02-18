package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.MeshProxy;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	/** <b>Модификатор Twist.</b> Скручивает меш вдоль определенной оси координат. */
	public class Twist extends Modifier implements IModifier {

		private var _vector:Vector3D = new Vector3D(0, 1, 0);
		private var _angle:Number;
		private var _d:Number;
		private var _dv:Vector3D = new Vector3D();
		private var _mat:Matrix3D = new Matrix3D();
		
		/** Центр действия модификатора на меш. */
		public var center:Vector3D = new Vector3D();
		
		/**
		 * Создает новый экземпляр класса Twist.
		 * @param	a угол скручивания меша.
		 */
		public function Twist(a:Number = 0) { _angle = a; }
		
		/** Угол скручивания меша. */
		public function get angle():Number { return _angle; }
		public function set angle(value:Number):void { _angle = value; }
	
		/** Ось вокруг которой осуществляется скручивание меша.*/
		public function get vector():Vector3D { return _vector; }
		public function set vector(value:Vector3D):void { 
			_vector = value;
			_vector.normalize();
		}
		
		/** @inheritDoc */
		public function apply():void {
			var vs:Vector.<VertexProxy> = mod.getVertices();
            var vc:int = vs.length;
			
			_dv.x = mod.maxX / 2;
			_dv.y = mod.maxY / 2;
			_dv.z = mod.maxZ / 2;
			
			var d:Number = -_vector.dotProduct(center);

			for(var i:int = 0; i < vc; i++) {
				var vertex:VertexProxy = vs[i];
				var dd:Number = vertex.vector.dotProduct(_vector) + d;
                twistPoint(vertex, (dd / _dv.length) * _angle);
			}
		}
		
		/** @inheritDoc */
		private function twistPoint(v:VertexProxy, a:Number):void {
			_mat.identity();
            _mat.appendTranslation(v.x, v.y, v.z);   
            _mat.appendRotation(a, _vector);
            v.x = _mat.rawData[12]; // n14
            v.y = _mat.rawData[13]; // n24
            v.z = _mat.rawData[14]; // n34
		}
	}
}
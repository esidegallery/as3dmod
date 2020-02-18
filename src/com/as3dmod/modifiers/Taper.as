package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;	
	
	import flash.geom.Matrix3D;
    import flash.geom.Vector3D;  

	/**
	 * 	<b>Модификатор Taper (конус).</b> Придает "конусность" объектам.
	 * 	@author Bartek Drozdz
	 */
	public class Taper extends Modifier implements IModifier {
		private var frc:Number;
		private var pow:Number;
		
		private var start:Number = 0;
		private var end:Number = 1;
		
		private var _m:Matrix3D;
		private var _temp:Vector3D;
		private var _vector:Vector3D = new Vector3D(1, 0, 1);
		private var _vector2:Vector3D = new Vector3D(0, 1, 0);
		
		/**
		 * Создает новый экземпляр класса Taper.
		 * @param	f сила действия модификатора.
		 */
		public function Taper(f:Number) {
			frc = f;
			pow = 1;
			
			_m = new Matrix3D();
			_temp = new Vector3D();
		}
		
		/** Сила действия модификатора. */
		public function set force(value:Number):void { frc = value; }
		public function get force():Number { return frc; }
		
		/** Закругление сторон конуса. */
		public function get power():Number { return pow; }
		public function set power(value:Number):void { pow = value; }
		
		/** @inheritDoc */
		public function apply():void {
			var vs:Vector.<VertexProxy> = mod.getVertices();
			var vc:int = vs.length;
			
			for (var i:int = 0;i < vc; i++) {
				var v:VertexProxy = vs[i];
				
				_temp.x = v.ratioX * _vector2.x;
				_temp.y = v.ratioY * _vector2.y;
				_temp.z = v.ratioZ * _vector2.z;
				
				var sc:Number = frc * Math.pow(_temp.length, pow);
				
				_m.identity();
				
				var xs:Number = 1 + sc * _vector.x;
				var ys:Number = 1 + sc * _vector.y;
				var zs:Number = 1 + sc * _vector.z;
				
				if (!xs) xs = 0.001;
				if (!ys) ys = 0.001;
				if (!zs) zs = 0.001;
				
                _m.appendScale(xs, ys, zs);
				
				_temp.x = v.x;
				_temp.y = v.y;
				_temp.z = v.z;
                                
                _temp = _m.transformVector(_temp);
				
				v.x = _temp.x;
				v.y = _temp.y;
				v.z = _temp.z;
			}
		}
	}
}
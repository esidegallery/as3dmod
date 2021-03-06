﻿package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;	
	
	import flash.geom.Vector3D;  

	/**
	 * <b>Модификатор Bloat.</b> Заставляет геометрию меша раздуваться.
	 * @author makc
	 */
	public class Bloat extends Modifier implements IModifier {
		private var _center:Vector3D = new Vector3D();
		
		/**  Координаты центра воздействия модификатора. */
		public function get center ():Vector3D { return _center; }
		public function set center (v:Vector3D):void { _center = v; }

		private var _r:Number = 0;
		/** Радиус "раздувания" геометрии меша. */
		public function get radius ():Number { return _r; }
		public function set radius (v:Number):void { _r = Math.max (0, v); }
		
		private var _a:Number = 0.01;
		/** Степень воздействия модификатора. */
		public function get a ():Number { return _a; }
		public function set a (v:Number):void { _a = Math.max (0, v); }

		private var _u:Vector3D = new Vector3D();
		
		/** Создает новый экземпляр класса Bloat. */
		public function Bloat() {}
		
		/** @inheritDoc */
		public function apply():void {
			var vs:Vector.<VertexProxy> = mod.getVertices();

			for each (var v:VertexProxy in vs) {
				// рассчитываем дистанцию от центра действия модификатора до позиции вершины
				_u.x = v.x - _center.x;
				_u.y = v.y - _center.y;
				_u.z = v.z - _center.z;

				// изменяем norm на norm + r * exp (-a * norm)
				var nn:Number = _u.length + _r * Math.exp ( - _u.length * _a);
				_u.normalize(); 
                _u.x *= nn; 
                _u.y *= nn; 
                _u.z *= nn;

				// двигаем вершину
				v.x = _u.x + _center.x;
				v.y = _u.y + _center.y;
				v.z = _u.z + _center.z;
			}
		}
	}
}
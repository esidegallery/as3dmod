package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.MeshProxy;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;
	import com.as3dmod.util.ModConstant;
	
	import flash.geom.Matrix;
	import flash.geom.Point;	

	/**
	 * 	<b>Модификатор Bend.</b> Cгибает меш вдоль одной из оси координат.
	 * 	@version 2.1
	 * 	@author Bartek Drozdz
	 * 	
	 * 	Изменения:
	 * 	2.1 - Параметры вращения теперь используют класс Matrix.
	 * 	2.0 - Добавлен параметр angle, задающий угол изгиба.
	 */
	public class Bend extends Modifier implements IModifier {
		private var _pi2a:Number = Math.PI * 2;
		private var _pi2b:Number = Math.PI / 2;
		
		private var _force:Number;
		private var _offset:Number;
		private var _angle:Number;
		private var _diagAngle:Number;
		private var _constraint:int = ModConstant.NONE;
		private var _switchAxes:Boolean = false;
		
		private var _max:int;
		private var _min:int;
		private var _mid:int;
		private var _width:Number;
		private var _height:Number;
		private var _origin:Number;
		private var _m1:Matrix;
		private var _m2:Matrix;
		private var _temp:Point;

		/**
		 * Создает новый экземпляр класса Bend.
		 * @param	f 	сила воздействия модификатора на меш.
		 * @param	o 	смещение места сгиба.
		 * @param	a	угол изгиба относительно вертикальной плоскости.
		 */
		public function Bend(f:Number=0, o:Number=0.5, a:Number=0) {
			_force = f;
			_offset = o;
			
			_m1 = new Matrix();
			_m2 = new Matrix();
			_temp = new Point();
			
			angle = a;
		}
		
		/** @inheritDoc */
		override public function setModifiable(mod:MeshProxy):void {
			super.setModifiable(mod);
			switchAxes = _switchAxes;
		}
		
		/** Переключает ось вдоль которой осуществляется сгиб.*/
		public function get switchAxes():Boolean { return _switchAxes; }
		public function set switchAxes(value:Boolean):void { 
			_max = value ? mod.midAxis : mod.maxAxis;
			_min = mod.minAxis;
			_mid = value ? mod.maxAxis : mod.midAxis;
				
			_width = mod.getSize(_max);	
			_height = mod.getSize(_mid);
			_origin = mod.getMin(_max);
			
			_diagAngle = Math.atan(_width / _height);
			
			_switchAxes = value;
		}
		
		/**
		 *  Сила воздействия модификатора на меш.
		 *  0 = нет воздействия, 1 = 180 градусов, 2 = 360 градусов и т.д.
		 *  Отрицательные значения также могут использоваться.
		 */
		public function set force(f:Number):void { _force = f; }		
		public function get force():Number { return _force; }
		
		/**
		 *  Смещение места сгиба.
		 *  Это значение может лежать в диапазоне от 0 до 1, где 1 является самым левым краем меша, а 0 - самым правым.
		 *  Сгиб меша будет происходить в месте, в зависимости от значения, которое имеет это свойство.
		 *  По умолчанию, это свойство имеет значение 0.5, что означает что сгиб будет происходить в середине меша.
		 */
		public function get offset():Number { return _offset; }
		public function set offset(offset:Number):void { _offset = offset; }
		
		/**
		 * 	Ограничение сгиба.
		 *  <p>Можно указать один из трех вариантов:</p> 
		 * 	<ul>
		 *  	<li>ModConstraint.NONE (по умолчанию) - вершины меша сгибаются по обеим сторонам от точки смещения.</li>
		 *  	<li>ModConstraint.LEFT - вершины меша сгибаются с левой стороны относительно точки смещения.</li>
		 *  	<li>ModConstraint.RIGHT - вершины меша сгибаются с правой стороны относительно точки смещения.</li>
		 *  </ul>
		 */
		public function set constraint(c:int):void { _constraint = c; }
		public function get constraint():int { return _constraint; }
		
		/** Угол диагонали меша. */
		public function get diagAngle():Number { return _diagAngle; }
		
		/** Угол изгиба относительно вертикальной плоскости. Задается в радианах. */
		public function get angle():Number { return _angle; }
		public function set angle(a:Number):void { 
			_angle = a; 
			_m1.identity();
			_m2.identity();
			_m1.rotate(_angle);
			_m2.rotate(-_angle);
		}
		
		/** @inheritDoc */
		public function apply():void {	
			if(force == 0) return;

			var vs:Vector.<VertexProxy> = mod.getVertices();
			var vc:int = vs.length;
			
			var distance:Number = _origin + _width * _offset;
			var radius:Number = _width / Math.PI / _force;
			var bendAngle:Number = _pi2a * (_width / (radius * _pi2a));
			var f:Number = _pi2b - bendAngle * _offset;

			for (var i:int = 0; i < vc; i++) {
				var v:VertexProxy = vs[i];
				
				var vmax:Number = _temp.x = v.getValue(_max);
				var vmid:Number = _temp.y = v.getValue(_mid);
				var vmin:Number = v.getValue(_min);

				var np:Point = _m1.transformPoint(_temp);
				vmax = np.x;
				vmid = np.y;

				var p:Number = (vmax - _origin) / _width;

				if ((constraint == ModConstant.LEFT && p <= _offset) || (constraint == ModConstant.RIGHT && p >= _offset)) {	
				} else {
					var fa:Number = f + bendAngle * p;
					var op:Number = Math.sin(fa) * (radius + vmin);
					var ow:Number = Math.cos(fa) * (radius + vmin);
					vmin = op - radius;
					vmax = distance - ow;
				}
				
				_temp.x = vmax;
				_temp.y = vmid;
				var np2:Point = _m2.transformPoint(_temp);
				vmax = np2.x;
				vmid = np2.y;
				
				v.setValue(_max, vmax);
				v.setValue(_mid, vmid);
				v.setValue(_min, vmin);
			}
		}
	}
}
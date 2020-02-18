package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;
	import com.as3dmod.util.Range;	
	
	import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

	/**
	 * <b>Модификатор Break.</b> Ломает меш.
	 * <br>
	 * <p>Это первая версия модификатора, он содержит некоторые жестко прописанные значения,
	 * которые делают его непригодным для использования в большинстве случаев.</p>
	 * 
	 * @version 0
	 * @author Bartek Drozdz
	 */
	public class Break extends Modifier implements IModifier {
		private var _offset:Number;
		private var _rm:Matrix3D;
		private var _pv:Vector3D;
		private var _temp:Vector3D;
		
		/** Ось, вокруг которой происходит ломка меша. */
		public var bv:Vector3D = new Vector3D(0, 1, 0);
		/** Угол поворота меша. */
		public var angle:Number;
		/** Диапазон чисел. */
		public var range:Range = new Range(0,1);
		
		/**
		 * Создает новый экземпляр класса Break.
		 * @param	o	смещение места ломки меша.
		 * @param	a	угол поворота меша.
		 */
		public function Break(o:Number = 0, a:Number = 0) {
			this.angle = a;
			this._offset = o;
			
			_rm = new Matrix3D();
			_pv = new Vector3D();
			_temp = new Vector3D();
		}
		
		/**
		 *  Смещение места ломки меша.
		 *  Это значение может лежать в диапазоне от 0 до 1, где 1 является самым левым краем меша, а 0 - самым правым.
		 *  Ломка меша будет происходить в месте, в зависимости от значения, которое имеет это свойство.
		 *  По умолчанию, это свойство имеет значение 0.5, что означает что ломка будет происходить в середине меша.
		 */
		public function get offset():Number { return _offset; }
		public function set offset(offset:Number):void { _offset = offset; }
		
		/** @inheritDoc */
		public function apply():void {
			var vs:Vector.<VertexProxy> = mod.getVertices();
			var vc:int = vs.length;
			
			_pv.z = -(mod.minZ + mod.depth * _offset);
			
			for (var i:int = 0; i < vc; i++) {
				var v:VertexProxy = vs[i];
				var c:Vector3D = v.vector;
				c.x += _pv.x;
				c.y += _pv.y;
				c.z += _pv.z;

                if(c.z >= 0 && range.isIn(v.ratioY)) {
                    var ta:Number = angle;
                    _rm.identity();
                    _rm.appendRotation(ta / Math.PI * 180, bv);
                    c = _rm.transformVector(c);
                }
				
				_temp.x = _pv.x;
				_temp.y = _pv.y;
				_temp.z = _pv.z;
                _temp.negate();
                        
                v.x = c.x += _temp.x;
                v.y = c.y += _temp.y;
                v.z = c.z += _temp.z;
			}
		}
	}
}
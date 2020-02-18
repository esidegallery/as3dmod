package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;
	
	import flash.geom.Vector3D;

	/**
	 * 	<b>Модификатор Pivot.</b> Позволяет переместить точку привязки (пивот) меша.
	 * 	<br>
	 * 	<br>Пивот будет перемещен на величину, указанную в векторе pivot.
	 * 	<br>В общих случаях этот модификатор используется так. В стек модификаторов добавляется модификатор
	 *  Pivot с нужными параметрами, применяется к мешу и удаляется из стека модификаторов (метод collapse) после этого.
	 * 	Таким образом, пивот меша будет перемещен, а модификатор будет удален из стека. Этот же самый стек после этого 
	 *  может быть использован для хранения других модификаторов. 
	 * 
	 * 	@version 1.0
	 * 	@author Bartek Drozdz
	 */
	public class Pivot extends Modifier implements IModifier {
		/** Вектор с значениями смещения пивота меша по каждой из оси координат. */
		public var pivot:Vector3D;
		private var _temp:Vector3D;
		
		/**
		 * Создает новый экземпляр класса Pivot.
		 * @param	x 	значение смещения пивота меша по оси X.
		 * @param	y	значение смещения пивота меша по оси Y.
		 * @param	z	значение смещения пивота меша по оси Z.
		 */
		public function Pivot(x:Number=0, y:Number=0, z:Number=0) {
			this.pivot = new Vector3D(x, y, z);
			_temp = new Vector3D();
		}
		
		/** Возвращает пивот меша в позицию центра меша. */
		public function setMeshCenter():void {
			pivot.x = -(mod.minX + mod.width / 2);
			pivot.y = -(mod.minY + mod.height / 2);
			pivot.z = -(mod.minZ + mod.depth / 2);
		}
		
		/** @inheritDoc */
		public function apply():void {
			var vs:Vector.<VertexProxy> = mod.getVertices();
			var vc:int = vs.length;

			for (var i:int = 0; i < vc; i++) {
				var v:VertexProxy = vs[i];
				v.x += pivot.x;
				v.y += pivot.y;
				v.z += pivot.z;
			}
			
			_temp.x = pivot.x;
			_temp.y = pivot.y;
			_temp.z = pivot.z;
            _temp.negate();
		
			mod.updateMeshPosition(_temp);
		}
	}
}
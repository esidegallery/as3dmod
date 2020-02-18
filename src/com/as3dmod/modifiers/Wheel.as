package com.as3dmod.modifiers {
	import com.as3dmod.IModifier;
	import com.as3dmod.core.MeshProxy;
	import com.as3dmod.core.Modifier;
	import com.as3dmod.core.VertexProxy;	
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	/**
	 * 	<b>Модификатор Wheel.</b> Используйте его для колес модели транспортного средства.
	 * 	<br>
	 * 	<p>У 3D колес автомобиля существует известная проблема, если предполагается поворачивать
	 * 	(рулить) и вращать его в одно и тоже время. Например, возьмем этот код:
	 * 	<br>
	 * 	<br><code><pre>
	 * 	wheel.rotationY = 10; // Поворачиваем колесо на 10 градусов влево
	 * 	wheel.rotationZ +- 5; // Вращаем колесо со скоростью 5
	 * 	</pre></code><br>
	 * 	В этом случае колесо будет катиться неправильно.</p>
	 * 	
	 * 	<p>Обычно, эта проблема решается таким способом. Колесо добавляется в другой Mesh, 
	 * 	поворачивается родитель и вращается само колесо, как показано ниже:
	 * 	<br><code><pre>
	 * 	steer.rotationY = 10; // Поворачиваем колесо на 10 градусов влево
	 * 	steer.wheel.rotationZ +- 5; // Вращаем колесо со скоростью 5
	 * 	</pre></code><br>
	 * 	В этом случае, колесо будет вести себя правильно. Но так делать может быть несовсем удобно, особенно при 
	 *  импорте сложных Collada моделей.</p>
	 * 	
	 * 	<p>Модификатор Wheel позволяет решить эту проблему более элегантней. Он использует математику для того чтобы 
	 *  вы имели возможность поворачивать и вращать один меш в одно и тоже время. Единственное, что вам нужно сделать, это указать
	 * 	вектор поворота и вектор вращения колеса - как правило, это будут 2 разные оси. По умолчанию используются такие оси:
	 * 	<ul>
	 * 	<li>поворот  - вокруг оси Y / new Vector3D(0, 1, 0)</li>
	 * 	<li>вращение - вокруг оси Z / new Vector3D(0, 0, 1)</li>
	 * 	</ul></p>
	 * 	
	 * 	<p>Это должно работать с большинством моделей автомобилей, импортированных из 3D-редакторов, поскольку это естественное положение колес.<br>
	 * 	Обратите внимание, примитивный цилиндр Papervision, который также может быть использован в качестве колеса, потребует уже другие оси
	 * 	(Y - вращение и Z или X - поворот).</p>
	 * 	
	 * 	@version 1.0
	 * 	@author Bartek Drozdz
	 */
	public class Wheel extends Modifier implements IModifier {
		/** Скорость вращения колеса. */
		public var speed:Number;
		/** Угол поворота колеса. */
		public var turn:Number;
		/** Вектор поворота. */
		public var steerVector:Vector3D = new Vector3D(0, 1, 0);
		/** Вектор вращения. */
		public var rollVector:Vector3D = new Vector3D(0, 0, 1);

		private var _roll:Number;
		private var _radius:Number;
		private var _deg:Number = 180 / Math.PI;
		private var _ms:Matrix3D;
        private var _mt:Matrix3D;
		private var _temp:Vector3D;
		
		/** Создает новый экземпляр класса Wheel. */
		public function Wheel() {
			speed = 0;
			turn = 0;
			_roll = 0;
			
			_ms = new Matrix3D();
			_mt = new Matrix3D();
			_temp = new Vector3D();
		}
		
		/** Величина одного шага вращения колеса. */
		public function get step():Number { return _radius * speed / Math.PI; }
		
		/** Периметр колеса. */
		public function get perimeter():Number { return _radius * 2 * Math.PI; }
		
		/** Радиус колеса. */
		public function get radius():Number { return _radius; }
		
		/** @inheritDoc */
		override public function setModifiable(mod:MeshProxy):void {
			super.setModifiable(mod);
			_radius = mod.width / 2;
		}
		
		/** @inheritDoc */
		public function apply():void {
			_roll += speed;
			
			_ms.identity();
			_mt.identity();
		
			if (turn != 0) {
				_mt.appendRotation(turn * _deg, steerVector);
				_temp.x = rollVector.x;
				_temp.y = rollVector.y;
				_temp.z = rollVector.z;
                _temp = _mt.transformVector(_temp);
                _ms.appendRotation(_roll * _deg, _temp);
			} else {
				_ms.appendRotation(_roll * _deg, rollVector);
			}
			
			var vs:Vector.<VertexProxy> = mod.getVertices();
			var vc:int = vs.length;
			
			for (var i:int = 0;i < vc; i++) {
				var v:VertexProxy = vs[i];
				_temp.x = v.x;
				_temp.y = v.y;
				_temp.z = v.z;
				
                if(turn != 0) _temp = _mt.transformVector(_temp);
                _temp = _ms.transformVector(_temp);
                v.x = _temp.x;
                v.y = _temp.y;
                v.z = _temp.z;
			}
		}
	}
}
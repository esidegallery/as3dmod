package com.as3dmod.plugins {
	import flash.utils.getDefinitionByName;
	
	import com.as3dmod.core.MeshProxy;	
	
	/** Класс PluginFactory содержит методы необходимые для работы с подключенными к библиотеке 3D-движками. */
	public class PluginFactory {
		
		/**
		 * Возвращает название класса меша для указанного 3D-движка.
		 * @param	lib3d	3D-движок.
		 * @return			название класса меша для указанного 3D-движка.
		 */
		public static function getMeshProxyClass(lib3d:Library3d):Class {
			return getDefinitionByName(lib3d.meshClass) as Class;
		}
		
		/**
		 * Возвращает экземпляр класса меша для указанного 3D-движка.
		 * @param	lib3d	3D-движок.
		 * @return			экземпляр класса меша для указанного 3D-движка.
		 */
		public static function getMeshProxy(lib3d:Library3d):MeshProxy {
			return new (getMeshProxyClass(lib3d))();
		}
	}
}
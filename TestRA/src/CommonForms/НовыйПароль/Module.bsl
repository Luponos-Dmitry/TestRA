///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ДляВнешнегоПользователя = Параметры.ДляВнешнегоПользователя;
	НовыйПароль = НовыйПароль(ДляВнешнегоПользователя);
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.ФормаЗакрыть.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьДругой(Команда)
	
	НовыйПароль = НовыйПароль(ДляВнешнегоПользователя);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НовыйПароль(ДляВнешнегоПользователя)
	
	СвойстваПароля = Пользователи.СвойстваПароля();
	СвойстваПароля.НаименьшаяДлина = 8;
	СвойстваПароля.Сложный = Истина;
	СвойстваПароля.УчестьНастройки = ?(ДляВнешнегоПользователя, "ДляВнешнихПользователей", "ДляПользователей");
	
	Возврат Пользователи.СоздатьПароль(СвойстваПароля);
	
КонецФункции

#КонецОбласти

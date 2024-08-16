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
	
	Если Параметры.Свойство("Отбор") И Параметры.Отбор.Свойство("Валюта") Тогда
		Валюта = Параметры.Отбор.Валюта;
	КонецЕсли;
	
	ОжидатьЗагрузкуКурсов = ОбщегоНазначения.РазделениеВключено() И ВыполняетсяЗагрузкаКурсов(Валюта);
	Если ОжидатьЗагрузкуКурсов Тогда
		Элементы.Страницы.ТекущаяСтраница = Элементы.ОжиданиеЗагрузки;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ОжидатьЗагрузкуКурсов Тогда
		ПодключитьОбработчикОжидания("ОжидатьЗагрузкуКурсов", 15, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ВыполняетсяЗагрузкаКурсов(Валюта)
	
	ВалютыЗагружаемыеИзИнтернета = Новый Массив;
	Если Метаданные.Обработки.Найти("ЗагрузкаКурсовВалют") <> Неопределено Тогда
		ВалютыЗагружаемыеИзИнтернета = Обработки["ЗагрузкаКурсовВалют"].ВалютыЗагружаемыеИзИнтернета();
	КонецЕсли;
	
	Если ВалютыЗагружаемыеИзИнтернета.Найти(Валюта) = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ТекстЗапроса =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	1 КАК Поле1
	|ИЗ
	|	РегистрСведений.КурсыВалют КАК КурсыВалют
	|ГДЕ
	|	КурсыВалют.Период > &Период
	|	И КурсыВалют.Валюта = &Валюта";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Период", '19800101');
	Запрос.УстановитьПараметр("Валюта", Валюта);
	
	Возврат Запрос.Выполнить().Пустой();
	
КонецФункции

&НаКлиенте
Процедура ОжидатьЗагрузкуКурсов()
	
	Если ВыполняетсяЗагрузкаКурсов(Валюта) Тогда
		ПодключитьОбработчикОжидания("ОжидатьЗагрузкуКурсов", 15, Истина);
	Иначе
		Элементы.Страницы.ТекущаяСтраница = Элементы.Курсы;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

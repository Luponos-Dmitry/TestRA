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
	
	Элементы.ФормаПродолжитьПопыткуУстановки.Видимость = Не Параметры.ПослеОшибкиПодключения;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.ДекорацияПояснение.Заголовок = ВнешниеКомпонентыСлужебныйКлиент.ТекстУстановкаВнешнейКомпонентыНевозможна(
		Параметры.ТекстПояснения);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДекорацияПояснениеОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоддерживаемыеКлиенты", Параметры.ПоддерживаемыеКлиенты);
	
	ОткрытьФорму("ОбщаяФорма.ПоддерживаемыеКлиентскиеПриложения", ПараметрыФормы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПродолжитьПопыткуУстановки(Команда)
	
	Закрыть(Истина);
	
КонецПроцедуры

#КонецОбласти


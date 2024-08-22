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
	
	ИзменятьВТранзакции = Параметры.ИзменятьВТранзакции;
	ОбрабатыватьРекурсивно = Параметры.ОбрабатыватьРекурсивно;
	РежимРазработчика = Параметры.РежимРазработчика;
	ОтключитьСвязиПараметровВыбора = Параметры.ОтключитьСвязиПараметровВыбора;
	ПрерыватьПриОшибке = Параметры.ПрерыватьПриОшибке;
	
	ЕстьПравоАдминистрированияДанных = ПравоДоступа("АдминистрированиеДанных", Метаданные);
	КлючСохраненияПоложенияОкна = ?(ЕстьПравоАдминистрированияДанных, "ЕстьПравоАдминистрированияДанных", "НетПраваАдминистрированияДанных");
	
	МожноПоказыватьСлужебныеРеквизиты = Не Параметры.КонтекстныйВызов И ЕстьПравоАдминистрированияДанных;
	Элементы.ГруппаПоказыватьСлужебныеРеквизиты.Видимость = МожноПоказыватьСлужебныеРеквизиты;
	Элементы.РежимРазработчика.Видимость = МожноПоказыватьСлужебныеРеквизиты;
	Элементы.ОтключитьСвязиПараметровВыбора.Видимость = МожноПоказыватьСлужебныеРеквизиты;
	
	Если МожноПоказыватьСлужебныеРеквизиты Тогда
		ПоказыватьСлужебныеРеквизиты = Параметры.ПоказыватьСлужебныеРеквизиты;
	КонецЕсли;
	
	Элементы.ГруппаОбрабатыватьРекурсивно.Видимость = Параметры.КонтекстныйВызов И Параметры.УчитыватьИерархию;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	УстановитьЭлементыФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИзменятьВТранзакцииПриИзменении(Элемент)
	
	УстановитьЭлементыФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	РезультатВыбора = Новый Структура;
	РезультатВыбора.Вставить("ИзменятьВТранзакции",            ИзменятьВТранзакции);
	РезультатВыбора.Вставить("ОбрабатыватьРекурсивно",         ОбрабатыватьРекурсивно);
	РезультатВыбора.Вставить("НастройкаПорции",                НастройкаПорции);
	РезультатВыбора.Вставить("ПроцентОбъектовВПорции",         ПроцентОбъектовВПорции);
	РезультатВыбора.Вставить("ПрерыватьПриОшибке",             ИзменятьВТранзакции Или ПрерыватьПриОшибке);
	РезультатВыбора.Вставить("ПоказыватьСлужебныеРеквизиты",   ПоказыватьСлужебныеРеквизиты);
	РезультатВыбора.Вставить("РежимРазработчика",              РежимРазработчика);
	РезультатВыбора.Вставить("ОтключитьСвязиПараметровВыбора", ОтключитьСвязиПараметровВыбора);
	
	ОповеститьОВыборе(РезультатВыбора);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьЭлементыФормы()
	
	Элементы.ГруппаПрерываниеПриОшибке.Доступность = НЕ ИзменятьВТранзакции;
	
КонецПроцедуры

#КонецОбласти

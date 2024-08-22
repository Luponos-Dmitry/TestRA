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
	
	НастройкиПодсистемы = ОбновлениеИнформационнойБазыСлужебный.НастройкиПодсистемы();
	ТекстПодсказки      = НастройкиПодсистемы.ПоясненияДляРезультатовОбновления;
	
	Если Не ПустаяСтрока(ТекстПодсказки) Тогда
		Элементы.Подсказка.Заголовок = ТекстПодсказки;
	КонецЕсли;
	
	ПараметрыСообщения  = НастройкиПодсистемы.ПараметрыСообщенияОНевыполненныхОтложенныхОбработчиках;
	
	Если ЗначениеЗаполнено(ПараметрыСообщения.ТекстСообщения) Тогда
		Элементы.Сообщение.Заголовок = ПараметрыСообщения.ТекстСообщения;
	КонецЕсли;
	
	Если ПараметрыСообщения.КартинкаСообщения <> Неопределено Тогда
		Элементы.Картинка.Картинка = ПараметрыСообщения.КартинкаСообщения;
	КонецЕсли;
	
	Если ПараметрыСообщения.ЗапрещатьПродолжение Тогда
		Элементы.ФормаПродолжить.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Завершить(Команда)
	Закрыть(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьОбновление(Команда)
	Закрыть(Истина);
КонецПроцедуры

#КонецОбласти

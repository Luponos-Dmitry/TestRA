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
	
	РассылкаСсылка = Параметры.Ссылка;
	СостояниеРассылки = РассылкаОтчетов.ПолучитьСостояниеРассылкиОтчетов(РассылкаСсылка);
	
	Если СостояниеРассылки.СОшибками Тогда 
		Элементы.ЗаголовокДекорация.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Рассылка отчетов (%1) была отправлена не всем получателям. Повторить рассылку для получателей:'"),
			СостояниеРассылки.ПоследнийЗапускНачало);
	Иначе	
		Элементы.ЗаголовокДекорация.Заголовок = НСтр("ru = 'Повторная рассылка не требуется.'");
	КонецЕсли;
	
	ЗаполнитьПолучателейПовторнойРассылки(РассылкаСсылка, СостояниеРассылки);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПовторитьРассылку(Команда)
	
	Если Получатели.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	МассивРассылок = Новый Массив;
	МассивРассылок.Добавить(РассылкаСсылка);
	
	ПараметрыЗапуска = Новый Структура("МассивРассылок, Форма, ЭтоФормаЭлемента");
	ПараметрыЗапуска.МассивРассылок = МассивРассылок;
	ПараметрыЗапуска.Форма = ВладелецФормы;
	ПараметрыЗапуска.ЭтоФормаЭлемента = (ВладелецФормы = "Справочник.РассылкиОтчетов.Форма.ФормаЭлемента");
	
	СписокПолучателей = Новый Соответствие;
	Для Каждого СтрокаПолучатель Из Получатели Цикл
		СписокПолучателей.Вставить(СтрокаПолучатель.Получатель, СтрокаПолучатель.АдресЭлектроннойПочты);
	КонецЦикла;
	
	РассылкаОтчетовКлиент.ВыполнитьСейчасВФоне(СписокПолучателей, ПараметрыЗапуска);
	
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьПолучателейПовторнойРассылки(РассылкаСсылка, СостояниеРассылки)
	
	ПолучателиПовторнойРассылки = РассылкаОтчетов.ПолучателиПовторнойРассылкиОтчетов(РассылкаСсылка,
		СостояниеРассылки.ПоследнийЗапускНачало, СостояниеРассылки.НомерСеанса);
	
	Для Каждого Получатель Из ПолучателиПовторнойРассылки Цикл
		СтрокаПолучатели = Получатели.Добавить();
		СтрокаПолучатели.Получатель = Получатель.Ключ;
		СтрокаПолучатели.АдресЭлектроннойПочты = Получатель.Значение;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

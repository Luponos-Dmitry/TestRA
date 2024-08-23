///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПараметрыИнформирования = ПользователиСлужебныйКлиент.ПараметрыИнформированияОПерезапуске();
	Если Не ЗначениеЗаполнено(ПараметрыИнформирования.ДатаПерезапуска) Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.ФормаНапомнитьЗавтра.Видимость = Ложь;
	Элементы.Картинка.Картинка = БиблиотекаКартинок.ДиалогВосклицание;
	
	ПредставлениеОсталосьМинут = ПользователиСлужебныйКлиент.ПредставлениеОсталосьМинутДоПерезапуска(
		ПользователиСлужебныйКлиент.ОсталосьМинутДоПерезапуска(ПараметрыИнформирования.ДатаПерезапуска));
		
	Элементы.Надпись.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Администратор изменил права доступа.
		           |Приложение будет перезапущено через %1, чтобы они вступили в силу.'"),
		ПредставлениеОсталосьМинут);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Перезапустить(Команда)
	
	СтандартныеПодсистемыКлиент.ПропуститьПредупреждениеПередЗавершениемРаботыСистемы();
	ЗавершитьРаботуСистемы(Истина, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура НапомнитьЗавтра(Команда)
	
	НапомнитьЗавтраНаСервере();
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура НапомнитьЗавтраНаСервере()
	
	ОбщегоНазначения.ХранилищеСистемныхНастроекСохранить("КонтрольИзмененияРолейПользователяИБ",
		"ДатаНапомнитьЗавтра", НачалоДня(ТекущаяДатаСеанса()) + 60*60*24);
	
КонецПроцедуры

#КонецОбласти

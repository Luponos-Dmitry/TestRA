///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Установить или снять блокировку информационной базы,
// исходя из значений реквизитов обработки.
//
Процедура ВыполнитьУстановку() Экспорт
	
	ВыполнитьУстановкуБлокировки(ЗапретитьРаботуПользователей);
	
КонецПроцедуры

// Отменить ранее установленную блокировку сеансов.
//
Процедура ОтменитьБлокировку() Экспорт
	
	ВыполнитьУстановкуБлокировки(Ложь);
	
КонецПроцедуры

// Зачитать параметры блокировки информационной базы 
// в реквизиты обработки.
//
Процедура ПолучитьПараметрыБлокировки() Экспорт
	
	Если Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		ТекущийРежим = ПолучитьБлокировкуСеансов();
		КодДляРазблокировки = ТекущийРежим.КодРазрешения;
	Иначе
		ТекущийРежим = СоединенияИБ.ПолучитьБлокировкуСеансовОбластиДанных();
	КонецЕсли;
	
	ЗапретитьРаботуПользователей = ТекущийРежим.Установлена 
		И (Не ЗначениеЗаполнено(ТекущийРежим.Конец) Или ТекущаяДатаСеанса() < ТекущийРежим.Конец);
	СообщениеДляПользователей = СоединенияИБКлиентСервер.ИзвлечьСообщениеБлокировки(ТекущийРежим.Сообщение);
	
	Если ЗапретитьРаботуПользователей Тогда
		НачалоДействияБлокировки    = ТекущийРежим.Начало;
		ОкончаниеДействияБлокировки = ТекущийРежим.Конец;
	Иначе
		// Если блокировка не установлена, можно предположить, что
		// пользователь открыл форму для установки блокировки.
		// Поэтому устанавливаем дату блокировки равной текущей дате.
		НачалоДействияБлокировки     = НачалоМинуты(ТекущаяДатаСеанса() + 15 * 60);
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьУстановкуБлокировки(Значение)
	
	Если Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		Блокировка = Новый БлокировкаСеансов;
		Блокировка.КодРазрешения    = КодДляРазблокировки;
		Блокировка.Параметр = СерверныеОповещения.КлючСеанса();
	Иначе
		Блокировка = СоединенияИБ.НовыеПараметрыБлокировкиСоединений();
	КонецЕсли;
	
	Блокировка.Начало           = НачалоДействияБлокировки;
	Блокировка.Конец            = ОкончаниеДействияБлокировки;
	Блокировка.Сообщение        = СоединенияИБ.СформироватьСообщениеБлокировки(СообщениеДляПользователей, 
		КодДляРазблокировки); 
	Блокировка.Установлена      = Значение;
	
	Если Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		УстановитьБлокировкуСеансов(Блокировка);
		
		УстановитьПривилегированныйРежим(Истина);
		СоединенияИБ.ОтправитьСерверноеОповещениеОбУстановкеБлокировки();
		УстановитьПривилегированныйРежим(Ложь);
	Иначе
		СоединенияИБ.УстановитьБлокировкуСеансовОбластиДанных(Блокировка);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
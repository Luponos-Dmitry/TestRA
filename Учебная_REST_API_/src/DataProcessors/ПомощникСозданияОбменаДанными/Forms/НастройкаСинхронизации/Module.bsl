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
	
	ОбменДаннымиСервер.ПроверитьВозможностьАдминистрированияОбменов();
	
	ИнициализироватьРеквизитыФормы();
	
	ИнициализироватьСвойстваФормы();
	
	УстановитьНачальноеОтображениеЭлементовФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ЗаполнитьТаблицуЭтаповНастройки();
	ОбновитьОтображениеТекущегоСостоянияНастройки();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	СсылкаСуществует   = Ложь;
	НастройкаЗавершена = Ложь;
	
	Если ЗначениеЗаполнено(УзелОбмена) Тогда
		НастройкаЗавершена = НастройкаСинхронизацииЗавершена(УзелОбмена, СсылкаСуществует);
		Если Не СсылкаСуществует Тогда
			// Закрытие формы при удалении настройки синхронизации.
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(УзелОбмена)
		Или Не НастройкаЗавершена
		Или (НастройкаРИБ И Не ПродолжениеНастройкиВПодчиненномУзлеРИБ И Не НачальныйОбразСоздан(УзелОбмена))Тогда
		ТекстПредупреждения = НСтр("ru = 'Настройка синхронизации данных еще не завершена.
		|Завершить работу с помощником? Настройку можно будет продолжить позже.'");
		ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияПроизвольнойФормы(
			ЭтотОбъект, Отказ, ЗавершениеРаботы, ТекстПредупреждения, "ЗакрытьФормуБезусловно");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если Не ЗавершениеРаботы Тогда
		Оповестить("ЗакрытаФормаПомощникаСозданияОбменаДанными");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодробноеОписаниеСинхронизацииДанных(Команда)
	
	ОбменДаннымиКлиент.ОткрытьПодробноеОписаниеСинхронизации(ОписаниеВариантаНастройки.ПодробнаяИнформацияПоОбмену);
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьПараметрыПодключения(Команда)
	
	Если ЭтоОбменСПриложениемВСервисе
		И (Не НастройкаНовойСинхронизации
			Или Не ТекущийЭтапНастройки = "НастройкаПодключения") Тогда
		СтрокаПредупреждение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Настройка подключения к ""%1"" уже выполнена.
			|Редактирование параметров подключения не предусмотрено.'"), УзелОбмена);
		ПоказатьПредупреждение(, СтрокаПредупреждение);
		Возврат;
	КонецЕсли;
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("НастроитьПараметрыПодключенияЗавершение", ЭтотОбъект);
	
	Если ОбменДаннымиСВнешнейСистемой Тогда
		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОбменДаннымиСВнешнимиСистемами") Тогда
			Контекст = Новый Структура;
			Контекст.Вставить("ИдентификаторНастройки", ИдентификаторНастройки);
			Контекст.Вставить("ПараметрыПодключения", ПараметрыПодключенияВнешнейСистемы);
			Контекст.Вставить("Корреспондент", УзелОбмена);
			
			Если НастройкаНовойСинхронизации
				И ТекущийЭтапНастройки = "НастройкаПодключения" Тогда
				Контекст.Вставить("Режим", "НовоеПодключение");
			Иначе
				Контекст.Вставить("Режим", "РедактированиеПараметровПодключения");
			КонецЕсли;
			
			Отказ = Ложь;
			ИмяФормыПомощника  = "";
			ПараметрыПомощника = Новый Структура;
			
			МодульОбменДаннымиСВнешнимиСистемамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбменДаннымиСВнешнимиСистемамиКлиент");
			МодульОбменДаннымиСВнешнимиСистемамиКлиент.ПередНастройкойПараметровПодключения(
				Контекст, Отказ, ИмяФормыПомощника, ПараметрыПомощника);
			
			Если Не Отказ Тогда
				ОткрытьФорму(ИмяФормыПомощника,
					ПараметрыПомощника, ЭтотОбъект, , , , ОповещениеОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
			КонецЕсли;
		КонецЕсли;
		Возврат;
	ИначеЕсли ТекущийЭтапНастройки = "НастройкаПодключения" Тогда
		ПараметрыПомощника = Новый Структура;
		ПараметрыПомощника.Вставить("ИмяПланаОбмена",         ИмяПланаОбмена);
		ПараметрыПомощника.Вставить("ИдентификаторНастройки", ИдентификаторНастройки);
		Если ПродолжениеНастройкиВПодчиненномУзлеРИБ Тогда
			ПараметрыПомощника.Вставить("ПродолжениеНастройкиВПодчиненномУзлеРИБ");
		КонецЕсли;
		
		ОткрытьФорму("Обработка.ПомощникСозданияОбменаДанными.Форма.НастройкаПодключения",
			ПараметрыПомощника, ЭтотОбъект, , , , ОповещениеОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	Иначе
		Отбор              = Новый Структура("Корреспондент", УзелОбмена);
		ЗначенияЗаполнения = Новый Структура("Корреспондент", УзелОбмена);
		
		ОбменДаннымиКлиент.ОткрытьФормуЗаписиРегистраСведенийПоОтбору(Отбор,
			ЗначенияЗаполнения, "НастройкиТранспортаОбменаДанными", ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьПодтверждениеПодключения(Команда)
	
	Если Не ОбменДаннымиСВнешнейСистемой
		Или ПолученыНастройкиXDTOКорреспондента(УзелОбмена) Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Подключение подтверждено.'"));
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ОбменДаннымиСВнешнимиСистемами") Тогда
		Контекст = Новый Структура;
		Контекст.Вставить("Режим",                  "ПодтверждениеПодключения");
		Контекст.Вставить("Корреспондент",          УзелОбмена);
		Контекст.Вставить("ИдентификаторНастройки", "ИдентификаторНастройки");
		Контекст.Вставить("ПараметрыПодключения",   ПараметрыПодключенияВнешнейСистемы);
		
		Отказ = Ложь;
		ИмяФормыПомощника  = "";
		ПараметрыПомощника = Новый Структура;
		
		МодульОбменДаннымиСВнешнимиСистемамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ОбменДаннымиСВнешнимиСистемамиКлиент");
		МодульОбменДаннымиСВнешнимиСистемамиКлиент.ПередНастройкойПараметровПодключения(
			Контекст, Отказ, ИмяФормыПомощника, ПараметрыПомощника);
		
		Если Не Отказ Тогда
			ОповещениеОЗакрытии = Новый ОписаниеОповещения("ПолучитьПодтверждениеПодключенияЗавершение", ЭтотОбъект);
			ОткрытьФорму(ИмяФормыПомощника,
				ПараметрыПомощника, ЭтотОбъект, , , , ОповещениеОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьПравилаОтправкиИПолученияДанных(Команда)
	
	ОповещениеПродолжения = Новый ОписаниеОповещения("НастроитьПравилаОтправкиИПолученияДанныхПродолжение", ЭтотОбъект);
	
	// Для плана обмена XDTO перед настройкой правил выгрузки и загрузки
	// должны быть получены настройки корреспондента.
	Если НастройкаXDTO Тогда
		ПрерватьНастройку = Ложь;
		ВыполнитьЗагрузкуНастроекXDTOПриНеобходимости(ПрерватьНастройку, ОповещениеПродолжения);
		
		Если ПрерватьНастройку Тогда
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("ПродолжитьНастройку",            Истина);
	Результат.Вставить("ПолученыДанныеДляСопоставления", ПолученыДанныеДляСопоставления);
	
	ВыполнитьОбработкуОповещения(ОповещениеПродолжения, Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьНачальныйОбразРИБ(Команда)
	
	ПараметрыПомощника = Новый Структура("Ключ, Узел", УзелОбмена, УзелОбмена);
			
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("СоздатьНачальныйОбразРИБЗавершение", ЭтотОбъект);
	ОткрытьФорму(ИмяФормыСозданияНачальногоОбраза,
		ПараметрыПомощника, ЭтотОбъект, , , , ОповещениеОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьСопоставлениеИЗагрузкуДанных(Команда)
	
	ОповещениеПродолжения = Новый ОписаниеОповещения("ВыполнитьСопоставлениеИЗагрузкуДанныхПродолжение", ЭтотОбъект);
	
	ПараметрыПомощника = Новый Структура;
	ПараметрыПомощника.Вставить("ОтправитьДанные",     Ложь);
	ПараметрыПомощника.Вставить("НастройкаРасписания", Ложь);
	
	Если ЭтоОбменСПриложениемВСервисе Тогда
		ПараметрыПомощника.Вставить("ОбластьДанныхКорреспондента", ОбластьДанныхКорреспондента);
	КонецЕсли;
	
	ВспомогательныеПараметры = Новый Структура;
	ВспомогательныеПараметры.Вставить("ПараметрыПомощника",  ПараметрыПомощника);
	ВспомогательныеПараметры.Вставить("ОповещениеОЗакрытии", ОповещениеПродолжения);
	
	ОбменДаннымиКлиент.ОткрытьПомощникСопоставленияОбъектовОбработкаКоманды(УзелОбмена,
		ЭтотОбъект, ВспомогательныеПараметры);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьНачальнуюВыгрузкуДанных(Команда)

	Отказ = Ложь;
	
	ПередВыполнениемНачальнойВыгрузки(Отказ);
	Если Отказ Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ПараметрыПомощника = Новый Структура;
	ПараметрыПомощника.Вставить("УзелОбмена", УзелОбмена);
	ПараметрыПомощника.Вставить("НачальнаяВыгрузка");
	
	Если МодельСервиса Тогда
		ПараметрыПомощника.Вставить("ЭтоОбменСПриложениемВСервисе", ЭтоОбменСПриложениемВСервисе);
		ПараметрыПомощника.Вставить("ОбластьДанныхКорреспондента",  ОбластьДанныхКорреспондента);
	КонецЕсли;
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ВыполнитьНачальнуюВыгрузкуДанныхЗавершение", ЭтотОбъект);
	ОткрытьФорму("Обработка.ПомощникИнтерактивногоОбменаДанными.Форма.ВыгрузкаДанныхДляСопоставления",
		ПараметрыПомощника, ЭтотОбъект, , , , ОповещениеОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПередВыполнениемНачальнойВыгрузки(Отказ)
	
	МассивЗначений = Новый Массив(3);
	МассивЗначений[0] = ПредопределенноеЗначение("Перечисление.ВидыТранспортаСообщенийОбмена.COM");
	МассивЗначений[1] = ПредопределенноеЗначение("Перечисление.ВидыТранспортаСообщенийОбмена.WS");
	// WSПассивныйРежим - проверять не нужно, так как при пассивном соединении управляющий корреспондент самостоятельно
	//                    получить сведения при соединении.
	
	ВидТранспортаПоддерживаетПрямоеПодключение = (МассивЗначений.Найти(ВидТранспорта) <> Неопределено);
	Если НЕ ВидТранспортаПоддерживаетПрямоеПодключение
		ИЛИ ПоддерживаетсяСопоставлениеДанных Тогда
		
		Возврат;
		
	КонецЕсли;
	
	РезультатПроверки = НастройкаКорреспондентаЗавершена(УзелОбмена, ВидТранспорта);
	Если НЕ РезультатПроверки.НастройкаЗавершена Тогда
		
		Отказ = Истина;
		ПоказатьПредупреждение(Неопределено, РезультатПроверки.СообщениеОбОшибке);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НастройкаКорреспондентаЗавершена(УзелОбмена, ВидТранспорта)
	
	ДанныеПроверки = Новый Структура;
	ДанныеПроверки.Вставить("СообщениеОбОшибке", "");
	ДанныеПроверки.Вставить("СообщениеОбОшибкеПользователю", "");
	ДанныеПроверки.Вставить("НастройкаЗавершена", Ложь);
	ДанныеПроверки.Вставить("ПолученыДанныеДляСопоставления", Ложь);
	
	УстановитьПривилегированныйРежим(Истина);
	Если ВидТранспорта = Перечисления.ВидыТранспортаСообщенийОбмена.WS Тогда
	
		ПараметрыПодключения = РегистрыСведений.НастройкиТранспортаОбменаДанными.НастройкиТранспортаWS(УзелОбмена, Неопределено);
		
		
		ЕстьПодключение = ОбменДаннымиВебСервис.ЕстьПодключениеККорреспонденту(УзелОбмена,
			ПараметрыПодключения, ДанныеПроверки.СообщениеОбОшибкеПользователю, ДанныеПроверки.НастройкаЗавершена, ДанныеПроверки.ПолученыДанныеДляСопоставления);
			
		Если НЕ ЕстьПодключение Тогда
			
			ШаблонСообщения = НСтр("ru = 'Не удалось подключиться к приложению %1, по причине ""%2"".
				|Убедитесь, что:
				|- введен правильный пароль;
				|- указан корректный адрес для подключения;
				|- приложение доступно по указанному в настройках адресу;
				|- настройка синхронизации не была удалена в приложении в Интернете.
				|Повторите попытку синхронизации.'", ОбщегоНазначения.КодОсновногоЯзыка());
			ДанныеПроверки.СообщениеОбОшибке = СтрШаблон(ШаблонСообщения, УзелОбмена.Наименование, ДанныеПроверки.СообщениеОбОшибкеПользователю);
			
		ИначеЕсли НЕ ДанныеПроверки.НастройкаЗавершена Тогда
			
			ШаблонСообщения = НСтр("ru = 'Для продолжения перейдите в программу ""%1"" и завершите в ней настройку синхронизации. 
				|Выполнение обмена данными отменено.'", ОбщегоНазначения.КодОсновногоЯзыка());
			ДанныеПроверки.СообщениеОбОшибке = СтрШаблон(ШаблонСообщения, УзелОбмена.Наименование);
			
		КонецЕсли;
		
	Иначе
		
		ВнешнееСоединение = ОбменДаннымиПовтИсп.ПолучитьВнешнееСоединениеДляУзлаИнформационнойБазы(УзелОбмена, ДанныеПроверки.СообщениеОбОшибке);
		Если ВнешнееСоединение = Неопределено Тогда
			
			Возврат ДанныеПроверки;
			
		КонецЕсли;
		
		ИмяПланаОбмена = ОбменДаннымиПовтИсп.ПолучитьИмяПланаОбмена(УзелОбмена);
		
		ЭтотУзелПланаОбмена = ОбменДаннымиПовтИсп.ПолучитьЭтотУзелПланаОбмена(ИмяПланаОбмена);
		КодУзла = ОбменДаннымиСервер.ИдентификаторЭтогоУзлаДляОбмена(ЭтотУзелПланаОбмена);
		
		ВнешнееСоединениеУзелПланаОбмена = ВнешнееСоединение.ОбменДаннымиСервер.УзелПланаОбменаПоКоду(ИмяПланаОбмена, КодУзла);
		Если ВнешнееСоединениеУзелПланаОбмена = Неопределено Тогда
			
			ШаблонСообщения = НСтр("ru = 'Ошибка. В программе ""%1"" не найдена настройка синхронизации для этой программы.
					|Выполнение обмена данными отменено.'", ОбщегоНазначения.КодОсновногоЯзыка());
			ДанныеПроверки.СообщениеОбОшибке = СтрШаблон(ШаблонСообщения, УзелОбмена.Наименование);
			
		КонецЕсли;
		
		ДанныеПроверки.НастройкаЗавершена = ВнешнееСоединение.ОбменДаннымиСервер.НастройкаСинхронизацииЗавершена(ВнешнееСоединениеУзелПланаОбмена);
		Если НЕ ДанныеПроверки.НастройкаЗавершена Тогда
				
			ШаблонСообщения = НСтр("ru = 'Для продолжения перейдите в программу ""%1"" и завершите в ней настройку синхронизации. 
				|Выполнение обмена данными отменено.'", ОбщегоНазначения.КодОсновногоЯзыка());
			ДанныеПроверки.СообщениеОбОшибке = СтрШаблон(ШаблонСообщения, УзелОбмена.Наименование);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ДанныеПроверки;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПрочитатьВидТранспортаДляУзла(УзелОбмена)
	
	Возврат РегистрыСведений.НастройкиТранспортаОбменаДанными.ВидТранспортаСообщенийОбменаПоУмолчанию(УзелОбмена);
	
КонецФункции

&НаСервереБезКонтекста
Функция СостояниеНастройкиСинхронизации(УзелОбмена)
	
	Результат = Новый Структура;
	Результат.Вставить("НастройкаСинхронизацииЗавершена",           НастройкаСинхронизацииЗавершена(УзелОбмена));
	Результат.Вставить("НачальныйОбразСоздан",                      НачальныйОбразСоздан(УзелОбмена));
	Результат.Вставить("ПолученоСообщениеСДаннымиДляСопоставления", ОбменДаннымиСервер.ПолученоСообщениеСДаннымиДляСопоставления(УзелОбмена));
	Результат.Вставить("ПолученыНастройкиXDTOКорреспондента",       ПолученыНастройкиXDTOКорреспондента(УзелОбмена));
	
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолученыНастройкиXDTOКорреспондента(УзелОбмена)
	
	НастройкиКорреспондента = ОбменДаннымиXDTOСервер.ПоддерживаемыеОбъектыФорматаКорреспондента(УзелОбмена, "ОтправкаПолучение");
	
	Возврат НастройкиКорреспондента.Количество() > 0;
	
КонецФункции

&НаСервереБезКонтекста
Функция НачальныйОбразСоздан(УзелОбмена)
	
	Возврат РегистрыСведений.ОбщиеНастройкиУзловИнформационныхБаз.НачальныйОбразСоздан(УзелОбмена);
	
КонецФункции

&НаКлиенте
Процедура НастроитьПараметрыПодключенияЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если РезультатЗакрытия <> Неопределено
		И ТипЗнч(РезультатЗакрытия) = Тип("Структура") Тогда
		
		Если РезультатЗакрытия.Свойство("УзелОбмена") Тогда
			УзелОбмена = РезультатЗакрытия.УзелОбмена;
			КлючУникальности = ИмяПланаОбмена + "_" + ИдентификаторНастройки + "_" + УзелОбмена.УникальныйИдентификатор();
			
			Если ОбменДаннымиСВнешнейСистемой Тогда
				ОбновитьПараметрыПодключенияВнешнейСистемы(УзелОбмена, ПараметрыПодключенияВнешнейСистемы);
			КонецЕсли;
			
			Если ЗначениеЗаполнено(УзелОбмена) Тогда
				
				ВидТранспорта = ПрочитатьВидТранспортаДляУзла(УзелОбмена);
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если МодельСервиса Тогда
			РезультатЗакрытия.Свойство("ЭтоОбменСПриложениемВСервисе", ЭтоОбменСПриложениемВСервисе);
			РезультатЗакрытия.Свойство("ОбластьДанныхКорреспондента",  ОбластьДанныхКорреспондента);
		КонецЕсли;
		
		Если РезультатЗакрытия.Свойство("ЕстьДанныеДляСопоставления")
			И РезультатЗакрытия.ЕстьДанныеДляСопоставления Тогда
			ПолученыДанныеДляСопоставления = Истина;
		КонецЕсли;
		
		ЗаполнитьТаблицуЭтаповНастройки();
		ОбновитьОтображениеТекущегоСостоянияНастройки();
		
		Если ТекущийЭтапНастройки = "НастройкаПодключения" Тогда
			ПерейтиКСледующемуЭтапуНастройки();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОбновитьПараметрыПодключенияВнешнейСистемы(УзелОбмена, ПараметрыПодключенияВнешнейСистемы)
	
	ПараметрыПодключенияВнешнейСистемы = РегистрыСведений.НастройкиТранспортаОбменаДанными.НастройкиТранспортаВнешнейСистемы(УзелОбмена);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьПодтверждениеПодключенияЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если ПолученыНастройкиXDTOКорреспондента(УзелОбмена) Тогда
		ПерейтиКСледующемуЭтапуНастройки();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьЗагрузкуНастроекXDTOПриНеобходимости(ПрерватьНастройку, ОповещениеПродолжения)
	
	СостояниеНастройки = СостояниеНастройкиСинхронизации(УзелОбмена);
	Если Не СостояниеНастройки.НастройкаСинхронизацииЗавершена
			И Не СостояниеНастройки.ПолученыНастройкиXDTOКорреспондента Тогда
		
		ПараметрыЗагрузки = Новый Структура;
		ПараметрыЗагрузки.Вставить("УзелОбмена", УзелОбмена);
		
		ОткрытьФорму("Обработка.ПомощникСозданияОбменаДанными.Форма.ЗагрузкаНастроекXDTO",
			ПараметрыЗагрузки, ЭтотОбъект, , , , ОповещениеПродолжения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
			
		ПрерватьНастройку = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьПравилаОтправкиИПолученияДанныхПродолжение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(РезультатЗакрытия) <> Тип("Структура")
		ИЛИ Не РезультатЗакрытия.ПродолжитьНастройку Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если РезультатЗакрытия.ПолученыДанныеДляСопоставления
		И Не ПолученыДанныеДляСопоставления Тогда
		ПолученыДанныеДляСопоставления = РезультатЗакрытия.ПолученыДанныеДляСопоставления;
	КонецЕсли;
	
	ЗаполнитьТаблицуЭтаповНастройки();
	ОбновитьОтображениеТекущегоСостоянияНастройки();
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("НастроитьПравилаОтправкиИПолученияДанныхЗавершение", ЭтотОбъект);
	
	ПараметрыПроверки = Новый Структура;
	ПараметрыПроверки.Вставить("Корреспондент",          УзелОбмена);
	ПараметрыПроверки.Вставить("ИмяПланаОбмена",         ИмяПланаОбмена);
	ПараметрыПроверки.Вставить("ИдентификаторНастройки", ИдентификаторНастройки);
	
	НастройкаВыполнена = Ложь;
	ПередНастройкойСинхронизацииДанных(ПараметрыПроверки, НастройкаВыполнена, ИмяФормыПомощникаНастройкиСинхронизацииДанных);
	
	Если НастройкаВыполнена Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Настройка правил отправки и получения данных выполнена.'"));
		ВыполнитьОбработкуОповещения(ОповещениеОЗакрытии, Истина);
		Возврат;
	КонецЕсли;
	
	ПараметрыПомощника = Новый Структура;
	
	Если ПустаяСтрока(ИмяФормыПомощникаНастройкиСинхронизацииДанных) Тогда
		ПараметрыПомощника.Вставить("Ключ", УзелОбмена);
		ПараметрыПомощника.Вставить("ИмяФормыПомощника", "ПланОбмена.[ИмяПланаОбмена].ФормаОбъекта");
		
		ПараметрыПомощника.ИмяФормыПомощника = СтрЗаменить(ПараметрыПомощника.ИмяФормыПомощника,
			"[ИмяПланаОбмена]", ИмяПланаОбмена);
	Иначе
		ПараметрыПомощника.Вставить("УзелОбмена", УзелОбмена);
		ПараметрыПомощника.Вставить("ИмяФормыПомощника", ИмяФормыПомощникаНастройкиСинхронизацииДанных);
	КонецЕсли;
	
	ОткрытьФорму(ПараметрыПомощника.ИмяФормыПомощника,
		ПараметрыПомощника, ЭтотОбъект, , , , ОповещениеОЗакрытии, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьПравилаОтправкиИПолученияДанныхЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если ТекущийЭтапНастройки = "НастройкаПравил"
		И НастройкаСинхронизацииЗавершена(УзелОбмена) Тогда
		Оповестить("Запись_УзелПланаОбмена");
		Если ПродолжениеНастройкиВПодчиненномУзлеРИБ Тогда
			ОбновитьИнтерфейс();
		КонецЕсли;
		ПерейтиКСледующемуЭтапуНастройки();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьСопоставлениеИЗагрузкуДанныхПродолжение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если ТекущийЭтапНастройки = "СопоставлениеИЗагрузка"
		И ВыполненаЗагрузкаДанныхДляСопоставления(УзелОбмена) Тогда
		ПерейтиКСледующемуЭтапуНастройки();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьНачальныйОбразРИБЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если ТекущийЭтапНастройки = "НачальныйОбразРИБ"
		И НачальныйОбразСоздан(УзелОбмена) Тогда
		ПерейтиКСледующемуЭтапуНастройки();
	КонецЕсли;
	
	ОбновитьИнтерфейс();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьНачальнуюВыгрузкуДанныхЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если ТекущийЭтапНастройки = "НачальнаяВыгрузкаДанных"
		И РезультатЗакрытия = УзелОбмена Тогда
		ПерейтиКСледующемуЭтапуНастройки();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьОтображениеТекущегоСостоянияНастройки()
	
	// Видимость элементов настройки.
	Для Каждого ЭтапНастройки Из ЭтапыНастройки Цикл 		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, ЭтапНастройки.Группа, "Видимость", ЭтапНастройки.Используется);
	КонецЦикла;
	
	Если ПустаяСтрока(ТекущийЭтапНастройки) Тогда
		// Все этапы завершены.
		Для Каждого ЭтапНастройки Из ЭтапыНастройки Цикл
			Элементы[ЭтапНастройки.Группа].Доступность = Истина;
			Элементы[ЭтапНастройки.Кнопка].Шрифт = ОбщегоНазначенияКлиент.ШрифтСтиля("КомандаПомощникаНастройкиСинхронизацииОбычнаяШрифт");
					
			// Зеленый флажок только для основных этапов настройки.
			Если ЭтапНастройки.Основное Тогда
				Элементы[ЭтапНастройки.Панель].ТекущаяСтраница = Элементы[ЭтапНастройки.СтраницаУспешно];
			Иначе
				Элементы[ЭтапНастройки.Панель].ТекущаяСтраница = Элементы[ЭтапНастройки.СтраницаПустой];
			КонецЕсли;
		КонецЦикла;
	Иначе
		
		ТекущийЭтапНайден = Ложь;
		Для Каждого ЭтапНастройки Из ЭтапыНастройки Цикл
			Если ЭтапНастройки.Название = ТекущийЭтапНастройки Тогда
				Элементы[ЭтапНастройки.Группа].Доступность = Истина;
				Элементы[ЭтапНастройки.Панель].ТекущаяСтраница = Элементы[ЭтапНастройки.СтраницаТекущий];
				Элементы[ЭтапНастройки.Кнопка].Шрифт = ОбщегоНазначенияКлиент.ШрифтСтиля("КомандаПомощникаНастройкиСинхронизацииВажнаяШрифт");
				ТекущийЭтапНайден = Истина;
			ИначеЕсли Не ТекущийЭтапНайден Тогда
				Элементы[ЭтапНастройки.Группа].Доступность = Истина;
				Элементы[ЭтапНастройки.Панель].ТекущаяСтраница = Элементы[ЭтапНастройки.СтраницаУспешно];
				Элементы[ЭтапНастройки.Кнопка].Шрифт = ОбщегоНазначенияКлиент.ШрифтСтиля("КомандаПомощникаНастройкиСинхронизацииОбычнаяШрифт");
			Иначе
				Элементы[ЭтапНастройки.Группа].Доступность = Ложь;
				Элементы[ЭтапНастройки.Панель].ТекущаяСтраница = Элементы[ЭтапНастройки.СтраницаПустой];
				Элементы[ЭтапНастройки.Кнопка].Шрифт = ОбщегоНазначенияКлиент.ШрифтСтиля("КомандаПомощникаНастройкиСинхронизацииОбычнаяШрифт");
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого ЭтапНастройки Из ЭтапыНастройки Цикл
			Если НЕ ЭтапНастройки.Используется Тогда
				Элементы[ЭтапНастройки.Группа].Доступность = Ложь;
				Элементы[ЭтапНастройки.Панель].ТекущаяСтраница = Элементы[ЭтапНастройки.СтраницаПустой];
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
			
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиКСледующемуЭтапуНастройки()
	
	СледующаяСтрока = Неопределено;
	ТекущийЭтапНайден = Ложь;
	Для Каждого СтрокаЭтапыНастройки Из ЭтапыНастройки Цикл
		Если ТекущийЭтапНайден И СтрокаЭтапыНастройки.Используется Тогда
			СледующаяСтрока = СтрокаЭтапыНастройки;
			Прервать;
		КонецЕсли;
		
		Если СтрокаЭтапыНастройки.Название = ТекущийЭтапНастройки Тогда
			ТекущийЭтапНайден = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Если СледующаяСтрока <> Неопределено Тогда
		ТекущийЭтапНастройки = СледующаяСтрока.Название;
		
		Если ТекущийЭтапНастройки = "НастройкаПравил" Тогда
			ПараметрыПроверки = Новый Структура;
			ПараметрыПроверки.Вставить("Корреспондент",          УзелОбмена);
			ПараметрыПроверки.Вставить("ИмяПланаОбмена",         ИмяПланаОбмена);
			ПараметрыПроверки.Вставить("ИдентификаторНастройки", ИдентификаторНастройки);
			
			НастройкаВыполнена = НастройкаСинхронизацииЗавершена(УзелОбмена);
			Если Не НастройкаВыполнена Тогда
				Если Не НастройкаXDTO Или ПолученыНастройкиXDTOКорреспондента(УзелОбмена) Тогда
					ПередНастройкойСинхронизацииДанных(ПараметрыПроверки, НастройкаВыполнена, ИмяФормыПомощникаНастройкиСинхронизацииДанных);
				КонецЕсли;
			КонецЕсли;
			
			Если НастройкаВыполнена Тогда
				ПерейтиКСледующемуЭтапуНастройки();
				Возврат;
			КонецЕсли;
		КонецЕсли;
			
		Если НЕ СледующаяСтрока.Основное Тогда
			ТекущийЭтапНастройки = "";
		КонецЕсли;
	Иначе
		ТекущийЭтапНастройки = "";
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("ОбновитьОтображениеТекущегоСостоянияНастройки", 0.2, Истина);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция НастройкаСинхронизацииЗавершена(УзелОбмена, СсылкаСуществует = Ложь)
	
	СсылкаСуществует = ОбщегоНазначения.СсылкаСуществует(УзелОбмена);
	Возврат ОбменДаннымиСервер.НастройкаСинхронизацииЗавершена(УзелОбмена);
	
КонецФункции

&НаСервереБезКонтекста
Функция ВыполненаЗагрузкаДанныхДляСопоставления(УзелОбмена)
	
	Возврат Не ОбменДаннымиСервер.ПолученоСообщениеСДаннымиДляСопоставления(УзелОбмена);
	
КонецФункции

&НаСервереБезКонтекста
Процедура ПередНастройкойСинхронизацииДанных(ПараметрыПроверки, НастройкаВыполнена, ИмяФормыПомощника)
	
	Если ОбменДаннымиСервер.ЕстьАлгоритмМенеджераПланаОбмена("ПередНастройкойСинхронизацииДанных", ПараметрыПроверки.ИмяПланаОбмена) Тогда
		
		Контекст = Новый Структура;
		Контекст.Вставить("Корреспондент",          ПараметрыПроверки.Корреспондент);
		Контекст.Вставить("ИдентификаторНастройки", ПараметрыПроверки.ИдентификаторНастройки);
		Контекст.Вставить("НачальнаяНастройка",     Не НастройкаСинхронизацииЗавершена(ПараметрыПроверки.Корреспондент));
		
		ПланыОбмена[ПараметрыПроверки.ИмяПланаОбмена].ПередНастройкойСинхронизацииДанных(
			Контекст, НастройкаВыполнена, ИмяФормыПомощника);
		
		Если НастройкаВыполнена Тогда
			ОбменДаннымиСервер.ЗавершитьНастройкуСинхронизацииДанных(ПараметрыПроверки.Корреспондент);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#Область ИнициализацияФормыПриСоздании

&НаСервере
Процедура ИнициализироватьСвойстваФормы()
	
	Заголовок = ОписаниеВариантаНастройки.ЗаголовокПомощникаСозданияОбмена;
	
	Если ПустаяСтрока(Заголовок) Тогда
		Если НастройкаРИБ Тогда
			Заголовок = НСтр("ru = 'Настройка распределенной информационной базы'");
		Иначе
			Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Настройка синхронизации данных с ""%1""'"),
				ОписаниеВариантаНастройки.НаименованиеКорреспондента);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ИнициализироватьРеквизитыФормы()
	
	Параметры.Свойство("ОписаниеВариантаНастройки",    ОписаниеВариантаНастройки);
	Параметры.Свойство("ОбменДаннымиСВнешнейСистемой", ОбменДаннымиСВнешнейСистемой);
	
	НастройкаНовойСинхронизации = Параметры.Свойство("НастройкаНовойСинхронизации");
	ПродолжениеНастройкиВПодчиненномУзлеРИБ = Параметры.Свойство("ПродолжениеНастройкиВПодчиненномУзлеРИБ");
	
	МодельСервиса = ОбщегоНазначения.РазделениеВключено()
		И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных();
	
	Если НастройкаНовойСинхронизации Тогда
		ИмяПланаОбмена         = Параметры.ИмяПланаОбмена;
		ИдентификаторНастройки = Параметры.ИдентификаторНастройки;
		
		Если ОбменДаннымиСВнешнейСистемой Тогда
			Параметры.Свойство("ПараметрыПодключенияВнешнейСистемы", ПараметрыПодключенияВнешнейСистемы);
		Иначе
			Если Не ПродолжениеНастройкиВПодчиненномУзлеРИБ Тогда
				Если ОбменДаннымиСервер.ЭтоПодчиненныйУзелРИБ() Тогда
					ИмяПланаОбменаРИБ = ОбменДаннымиСервер.ГлавныйУзел().Метаданные().Имя;
					
					ПродолжениеНастройкиВПодчиненномУзлеРИБ = (ИмяПланаОбмена = ИмяПланаОбменаРИБ)
						И Не Константы.НастройкаПодчиненногоУзлаРИБЗавершена.Получить();
				КонецЕсли;
			КонецЕсли;
			
			Если ПродолжениеНастройкиВПодчиненномУзлеРИБ Тогда
				ОбменДаннымиСервер.ПриПродолженииНастройкиПодчиненногоУзлаРИБ();
				УзелОбмена = ОбменДаннымиСервер.ГлавныйУзел();
			КонецЕсли;
		КонецЕсли;
	Иначе
		УзелОбмена = Параметры.УзелОбмена;
		
		ИмяПланаОбмена         = ОбменДаннымиПовтИсп.ПолучитьИмяПланаОбмена(УзелОбмена);
		ИдентификаторНастройки = ОбменДаннымиСервер.СохраненныйВариантНастройкиУзлаПланаОбмена(УзелОбмена);
		
		Если МодельСервиса Тогда
			Параметры.Свойство("ОбластьДанныхКорреспондента",  ОбластьДанныхКорреспондента);
			Параметры.Свойство("ЭтоОбменСПриложениемВСервисе", ЭтоОбменСПриложениемВСервисе);
		КонецЕсли;
		
		Если ОбменДаннымиСВнешнейСистемой Тогда
			ОбновитьПараметрыПодключенияВнешнейСистемы(УзелОбмена, ПараметрыПодключенияВнешнейСистемы);
		КонецЕсли;
	КонецЕсли;
	
	Если ПродолжениеНастройкиВПодчиненномУзлеРИБ
		Или (Не ОбменДаннымиСВнешнейСистемой
			И ОписаниеВариантаНастройки = Неопределено) Тогда
		МодульПомощник = ОбменДаннымиСервер.МодульПомощникСозданияОбменаДанными();
		ОписаниеВариантаНастройки = МодульПомощник.СтруктураОписанияВариантаНастройки();
		
		ЗначенияНастроекДляВарианта = ОбменДаннымиСервер.ЗначениеНастройкиПланаОбмена(ИмяПланаОбмена,
			"НаименованиеКонфигурацииКорреспондента,
			|ЗаголовокКомандыДляСозданияНовогоОбменаДанными,
			|ЗаголовокПомощникаСозданияОбмена,
			|КраткаяИнформацияПоОбмену,
			|ПодробнаяИнформацияПоОбмену",
			ИдентификаторНастройки);
			
		ЗаполнитьЗначенияСвойств(ОписаниеВариантаНастройки, ЗначенияНастроекДляВарианта);
		ОписаниеВариантаНастройки.НаименованиеКорреспондента = ЗначенияНастроекДляВарианта.НаименованиеКонфигурацииКорреспондента;
	КонецЕсли;
	
	ВидТранспорта = Неопределено;
	Если ЗначениеЗаполнено(УзелОбмена) Тогда
		НастройкаЗавершена = НастройкаСинхронизацииЗавершена(УзелОбмена);
		ВидТранспорта = РегистрыСведений.НастройкиТранспортаОбменаДанными.ВидТранспортаСообщенийОбменаПоУмолчанию(УзелОбмена);
		ЕстьНастройкиТранспорта = ЗначениеЗаполнено(ВидТранспорта);
	КонецЕсли;
	
	РезервноеКопирование = Не МодельСервиса
		И Не ПродолжениеНастройкиВПодчиненномУзлеРИБ
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РезервноеКопированиеИБ");
		
	Если РезервноеКопирование Тогда
		МодульРезервноеКопированиеИБСервер = ОбщегоНазначения.ОбщийМодуль("РезервноеКопированиеИБСервер");
		
		НавигационнаяСсылкаОбработкиРезервногоКопирования =
			МодульРезервноеКопированиеИБСервер.НавигационнаяСсылкаОбработкиРезервногоКопирования();
	КонецЕсли;
		
	НастройкаРИБ                  = ОбменДаннымиПовтИсп.ЭтоПланОбменаРаспределеннойИнформационнойБазы(ИмяПланаОбмена);
	НастройкаXDTO                 = ОбменДаннымиСервер.ЭтоПланОбменаXDTO(ИмяПланаОбмена);
	НастройкаУниверсальногоОбмена = ОбменДаннымиПовтИсп.ЭтоУзелСтандартногоОбменаДанными(ИмяПланаОбмена); // без правил конвертации
	
	ДоступнаИнтерактивнаяОтправка = Не НастройкаРИБ И Не НастройкаУниверсальногоОбмена;
	
	Если Не ОбменДаннымиСВнешнейСистемой Тогда
	
		Если НастройкаНовойСинхронизации
			Или НастройкаРИБ
			Или НастройкаУниверсальногоОбмена Тогда
			ПолученыДанныеДляСопоставления = Ложь;
		ИначеЕсли ЭтоОбменСПриложениемВСервисе Тогда
			ПолученыДанныеДляСопоставления = ОбменДаннымиСервер.ПолученоСообщениеСДаннымиДляСопоставления(УзелОбмена);
		Иначе
			Если ВидТранспорта = Перечисления.ВидыТранспортаСообщенийОбмена.COM
				Или ВидТранспорта = Перечисления.ВидыТранспортаСообщенийОбмена.WS
				Или ВидТранспорта = Перечисления.ВидыТранспортаСообщенийОбмена.WSПассивныйРежим
				Или Не ЕстьНастройкиТранспорта Тогда
				ПолученыДанныеДляСопоставления = ОбменДаннымиСервер.ПолученоСообщениеСДаннымиДляСопоставления(УзелОбмена);
			Иначе
				ПолученыДанныеДляСопоставления = Истина;
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	ЗначенияНастроекДляВарианта = ОбменДаннымиСервер.ЗначениеНастройкиПланаОбмена(ИмяПланаОбмена,
		"ИмяФормыСозданияНачальногоОбраза,
		|ИмяФормыПомощникаНастройкиСинхронизацииДанных,
		|ПоддерживаетсяСопоставлениеДанных",
		ИдентификаторНастройки);
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ЗначенияНастроекДляВарианта);
	
	Если ПустаяСтрока(ИмяФормыСозданияНачальногоОбраза)
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаСФайлами") Тогда
		ИмяФормыСозданияНачальногоОбраза = "ОбщаяФорма.[ФормаСозданияНачальногоОбраза]";
		ИмяФормыСозданияНачальногоОбраза = СтрЗаменить(ИмяФормыСозданияНачальногоОбраза,
			"[ФормаСозданияНачальногоОбраза]", "СозданиеНачальногоОбразаСФайлами");
	КонецЕсли;
	
	ТекущийЭтапНастройки = "";
	Если НастройкаНовойСинхронизации Тогда
		ТекущийЭтапНастройки = "НастройкаПодключения";
	ИначеЕсли ОбменДаннымиСВнешнейСистемой
		И Не ПолученыНастройкиXDTOКорреспондента(УзелОбмена) Тогда
		ТекущийЭтапНастройки = "ПодтверждениеПодключения";
	ИначеЕсли Не НастройкаСинхронизацииЗавершена(УзелОбмена) Тогда
		ТекущийЭтапНастройки = "НастройкаПравил";
	ИначеЕсли НастройкаРИБ
		И Не ПродолжениеНастройкиВПодчиненномУзлеРИБ
		И Не НачальныйОбразСоздан(УзелОбмена) Тогда
		Если Не ПустаяСтрока(ИмяФормыСозданияНачальногоОбраза) Тогда
			ТекущийЭтапНастройки = "НачальныйОбразРИБ";
		КонецЕсли;
	ИначеЕсли ЗначениеЗаполнено(УзелОбмена) Тогда
		НомераСообщений = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(УзелОбмена, "НомерПринятого, НомерОтправленного");
		Если НомераСообщений.НомерПринятого = 0
			И НомераСообщений.НомерОтправленного = 0
			И ОбменДаннымиСервер.ПолученоСообщениеСДаннымиДляСопоставления(УзелОбмена) Тогда
			ТекущийЭтапНастройки = "СопоставлениеИЗагрузка";
		КонецЕсли;
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Функция ДобавитьЭтапНастройки(Название, Кнопка, ЭлементыФормы, Используется, Основное = Истина)
	
	СтрокаЭтап = ЭтапыНастройки.Добавить();
	СтрокаЭтап.Название        = Название;
	СтрокаЭтап.Кнопка          = Кнопка;
	СтрокаЭтап.Используется    = Используется;
	СтрокаЭтап.Основное        = Основное;
	
	ЗаполнитьЗначенияСвойств(СтрокаЭтап, ЭлементыФормы);
	
	Возврат СтрокаЭтап;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьТаблицуЭтаповНастройки()
	
	ЭтапыНастройки.Очистить();

	// Настройка подключения
	ЭтапИспользуется = ЕстьНастройкиТранспорта Или НастройкаНовойСинхронизации;
	
	ЭлементыФормы = Новый Структура;
	ЭлементыФормы.Вставить("Группа"			, Элементы.ГруппаНастройкаПодключения.Имя);
	ЭлементыФормы.Вставить("Панель"			, Элементы.ПанельНастройкаПодключения.Имя);
	ЭлементыФормы.Вставить("СтраницаУспешно", Элементы.СтраницаНастройкаПодключенияУспешно.Имя);
	ЭлементыФормы.Вставить("СтраницаТекущий", Элементы.СтраницаНастройкаПодключенияТекущий.Имя);
	ЭлементыФормы.Вставить("СтраницаПустой"	, Элементы.СтраницаНастройкаПодключенияПустой.Имя);
	
	ДобавитьЭтапНастройки("НастройкаПодключения", "НастроитьПараметрыПодключения", ЭлементыФормы, ЭтапИспользуется);

	// Подтверждение подключения	
	ЭтапИспользуется = ОбменДаннымиСВнешнейСистемой;
	
	ЭлементыФормы = Новый Структура;
	ЭлементыФормы.Вставить("Группа"			, Элементы.ГруппаПодтверждениеПодключения.Имя);
	ЭлементыФормы.Вставить("Панель"			, Элементы.ПанельПодтверждениеПодключения.Имя);
	ЭлементыФормы.Вставить("СтраницаУспешно", Элементы.СтраницаПодтверждениеПодключенияУспешно.Имя);
	ЭлементыФормы.Вставить("СтраницаТекущий", Элементы.СтраницаПодтверждениеПодключенияТекущий.Имя);
	ЭлементыФормы.Вставить("СтраницаПустой"	, Элементы.СтраницаПодтверждениеПодключенияПустой.Имя);
	
	ДобавитьЭтапНастройки("ПодтверждениеПодключения", "ПолучитьПодтверждениеПодключения", ЭлементыФормы, ЭтапИспользуется);
		
	// Настройка правил
	ЭлементыФормы = Новый Структура;
	ЭлементыФормы.Вставить("Группа"			, Элементы.ГруппаНастройкаПравил.Имя);
	ЭлементыФормы.Вставить("Панель"			, Элементы.ПанельНастройкаПравил.Имя);
	ЭлементыФормы.Вставить("СтраницаУспешно", Элементы.СтраницаНастройкаПравилУспешно.Имя);
	ЭлементыФормы.Вставить("СтраницаТекущий", Элементы.СтраницаНастройкаПравилТекущий.Имя);
	ЭлементыФормы.Вставить("СтраницаПустой"	, Элементы.СтраницаНастройкаПравилПустой.Имя);
	
	ДобавитьЭтапНастройки("НастройкаПравил", "НастроитьПравилаОтправкиИПолучения", ЭлементыФормы, Истина);
		
	// Начальный образ РИБ	
	ЭтапИспользуется = Не ОбменДаннымиСВнешнейСистемой
		И НастройкаРИБ
		И Не ПродолжениеНастройкиВПодчиненномУзлеРИБ
		И Не ПустаяСтрока(ИмяФормыСозданияНачальногоОбраза);
		
	ЭлементыФормы = Новый Структура;
	ЭлементыФормы.Вставить("Группа"			, Элементы.ГруппаНачальныйОбразРИБ.Имя);
	ЭлементыФормы.Вставить("Панель"			, Элементы.ПанельНачальныйОбразРИБ.Имя);
	ЭлементыФормы.Вставить("СтраницаУспешно", Элементы.СтраницаНачальныйОбразРИБУспешно.Имя);
	ЭлементыФормы.Вставить("СтраницаТекущий", Элементы.СтраницаНачальныйОбразРИБТекущий.Имя);
	ЭлементыФормы.Вставить("СтраницаПустой"	, Элементы.СтраницаНачальныйОбразРИБПустой.Имя);
	
	ДобавитьЭтапНастройки("НачальныйОбразРИБ", "СоздатьНачальныйОбразРИБ", ЭлементыФормы, ЭтапИспользуется);
		
	// Сопоставление и загрузка	
	ЭтапИспользуется = Не ОбменДаннымиСВнешнейСистемой 
		И Не НастройкаРИБ
		И Не НастройкаУниверсальногоОбмена
		И ПолученыДанныеДляСопоставления
		И ПоддерживаетсяСопоставлениеДанных <> Ложь;
		
	ЭлементыФормы = Новый Структура;
	ЭлементыФормы.Вставить("Группа"			, Элементы.ГруппаСопоставлениеИЗагрузка.Имя);
	ЭлементыФормы.Вставить("Панель"			, Элементы.ПанельСопоставлениеИЗагрузка.Имя);
	ЭлементыФормы.Вставить("СтраницаУспешно", Элементы.СтраницаСопоставлениеИЗагрузкаУспешно.Имя);
	ЭлементыФормы.Вставить("СтраницаТекущий", Элементы.СтраницаСопоставлениеИЗагрузкаТекущий.Имя);
	ЭлементыФормы.Вставить("СтраницаПустой"	, Элементы.СтраницаСопоставлениеИЗагрузкаПустой.Имя);
	
	ДобавитьЭтапНастройки("СопоставлениеИЗагрузка", "ВыполнитьСопоставлениеИЗагрузкуДанных", ЭлементыФормы, ЭтапИспользуется);
		
	// Начальная выгрузка данных
	ЭтапИспользуется = Не ОбменДаннымиСВнешнейСистемой
		И ДоступнаИнтерактивнаяОтправка
		И (ЕстьНастройкиТранспорта
			Или НастройкаНовойСинхронизации);
			
	ЭлементыФормы = Новый Структура;
	ЭлементыФормы.Вставить("Группа"			, Элементы.ГруппаНачальнаяВыгрузкаДанных.Имя);
	ЭлементыФормы.Вставить("Панель"			, Элементы.ПанельНачальнаяВыгрузкаДанных.Имя);
	ЭлементыФормы.Вставить("СтраницаУспешно", Элементы.СтраницаНачальнаяВыгрузкаДанныхУспешно.Имя);
	ЭлементыФормы.Вставить("СтраницаТекущий", Элементы.СтраницаНачальнаяВыгрузкаДанныхТекущий.Имя);
	ЭлементыФормы.Вставить("СтраницаПустой"	, Элементы.СтраницаНачальнаяВыгрузкаДанныхПустой.Имя);
	
	ДобавитьЭтапНастройки("НачальнаяВыгрузкаДанных", "ВыполнитьНачальнуюВыгрузкуДанных", ЭлементыФормы, ЭтапИспользуется);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьНачальноеОтображениеЭлементовФормы()
	
	Элементы.ДекорацияКраткаяИнформацияПоОбменуНадпись.Заголовок = ОписаниеВариантаНастройки.КраткаяИнформацияПоОбмену;
	Элементы.ПодробноеОписаниеСинхронизацииДанных.Видимость = ЗначениеЗаполнено(ОписаниеВариантаНастройки.ПодробнаяИнформацияПоОбмену);
	Элементы.ГруппаРезервноеКопирование.Видимость = РезервноеКопирование;
	Элементы.ПолучитьПодтверждениеПодключения.РасширеннаяПодсказка.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		Элементы.ПолучитьПодтверждениеПодключения.РасширеннаяПодсказка.Заголовок,
		ОписаниеВариантаНастройки.НаименованиеКорреспондента);
		
	Если РезервноеКопирование Тогда
		Элементы.ДекорацияРезервноеКопированиеНадпись.Заголовок = СтроковыеФункции.ФорматированнаяСтрока(
			НСтр("ru = 'Перед началом настройки новой синхронизации данных рекомендуется <a href=""%1"">создать резервную копию данных</a>.'"),
			НавигационнаяСсылкаОбработкиРезервногоКопирования);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
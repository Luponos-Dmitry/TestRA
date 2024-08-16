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
	
	Если Параметры.Свойство("УзелИнформационнойБазы") Тогда
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список, "УзелИнформационнойБазы", Параметры.УзелИнформационнойБазы); 	
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура РегистрироватьВсе(Команда)
		
	ДлительнаяОперация = НачатьВыполнениеРегистрации();
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ОбработатьРезультат", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания());

КонецПроцедуры

&НаКлиенте
Процедура РегистрироватьВыбранное(Команда)
	
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Для продолжения необходимо выделить строки'"));
		Возврат;
	КонецЕсли;
	
	ТаблицаОбъектов.Очистить();
	Для Каждого Строка Из ВыделенныеСтроки Цикл
		НоваяСтрока = ТаблицаОбъектов.Добавить();
		ЗначенияСтроки = Элементы.Список.ДанныеСтроки(Строка);
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ЗначенияСтроки);
	КонецЦикла;
	
	ДлительнаяОперация = НачатьВыполнениеРегистрацииВыбранного();
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ОбработатьРезультат", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания());
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ПараметрыОжидания()
	
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ТекстСообщения = "";
	ПараметрыОжидания.ВыводитьПрогрессВыполнения = Ложь;
	ПараметрыОжидания.ОповещениеОПрогрессеВыполнения = Неопределено;
	ПараметрыОжидания.ОповещениеПользователя.Показать = Ложь;
	ПараметрыОжидания.ОповещениеПользователя.НавигационнаяСсылка = Неопределено;
	ПараметрыОжидания.ВыводитьОкноОжидания = Истина;
	ПараметрыОжидания.ВыводитьСообщения = Ложь;
	
	Возврат ПараметрыОжидания;

КонецФункции

&НаСервере
Функция НачатьВыполнениеРегистрацииВыбранного()
	
	Адрес = ПоместитьВоВременноеХранилище(ТаблицаОбъектов.Выгрузить());
	
	Возврат ДлительныеОперации.ВыполнитьПроцедуру(,
		"РегистрыСведений.ОбъектыНезарегистрированныеПриЗацикливании.РегистрироватьВыбранное",
		Адрес);
		
КонецФункции

&НаСервере
Функция НачатьВыполнениеРегистрации()
	
	Схема = Элементы.Список.ПолучитьИсполняемуюСхемуКомпоновкиДанных();
	Настройки = Элементы.Список.ПолучитьИсполняемыеНастройкиКомпоновкиДанных();

	Возврат ДлительныеОперации.ВыполнитьПроцедуру(,
		"РегистрыСведений.ОбъектыНезарегистрированныеПриЗацикливании.РегистрироватьВсе", 
		Схема, Настройки);
		
КонецФункции

// Параметры:
//  Результат - см. ДлительныеОперацииКлиент.НовыйРезультатДлительнойОперации
//  ДополнительныеПараметры - Неопределено
//
&НаКлиенте
Процедура ОбработатьРезультат(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда 
		Возврат;
	КонецЕсли;
		
	Если Результат.Статус = "Ошибка" Тогда
		СтандартныеПодсистемыКлиент.ВывестиИнформациюОбОшибке(
			Результат.ИнформацияОбОшибке);
	КонецЕсли;
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

#КонецОбласти
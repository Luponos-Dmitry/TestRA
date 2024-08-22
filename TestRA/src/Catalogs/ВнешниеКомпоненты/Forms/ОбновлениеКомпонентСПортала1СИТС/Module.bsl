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

	Если ТипЗнч(Параметры.ОбновляемыеКомпоненты) <> Тип("Массив") Или Параметры.ОбновляемыеКомпоненты.Количество() = 0 Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Некорректное значение параметра %1 формы %2.'"), 
			"ОбновляемыеКомпоненты", "ОбновлениеКомпонентСПортала1СИТС");
	КонецЕсли;

	ДанныеАутентификацииПорталаСохранены = ДанныеАутентификацииПорталаСохранены();
	ДоступнаЗагрузкаСПортала = ВнешниеКомпонентыСлужебный.ДоступнаЗагрузкаСПортала();

	ТекстПояснения = "";
	ПредложитьОбновление = Ложь;
	ПараметрОбновляемыеКомпоненты = Параметры.ОбновляемыеКомпоненты; // Массив из СправочникСсылка.ВнешниеКомпоненты
	РеквизитыКомпонент = ОбщегоНазначения.ЗначенияРеквизитовОбъектов(ПараметрОбновляемыеКомпоненты,
		"Идентификатор, Версия, ОбновлятьСПортала1СИТС");
	Для Каждого ОбновляемаяКомпонента Из ПараметрОбновляемыеКомпоненты Цикл
		Реквизиты = РеквизитыКомпонент[ОбновляемаяКомпонента];
		ТекстПояснения = ТекстПояснения + ВнешниеКомпонентыСлужебный.ПредставлениеКомпоненты(Реквизиты.Идентификатор,
			Реквизиты.Версия) + ?(Реквизиты.ОбновлятьСПортала1СИТС, "", " - " + НСтр("ru = 'обновление отключено'")
			+ ".") + Символы.ПС;

		ПредложитьОбновление = ПредложитьОбновление Или Реквизиты.ОбновлятьСПортала1СИТС;
		Если Реквизиты.ОбновлятьСПортала1СИТС Тогда
			ОбновляемыеКомпоненты.Добавить(ОбновляемаяКомпонента);
		КонецЕсли;
	КонецЦикла;

	Если ПредложитьОбновление Тогда

		Элементы.ДекорацияПояснение.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1
				 |Проверить и загрузить обновление компоненты?'"), ТекстПояснения);

		Элементы.ПодключитьИнтернетПоддержку.Видимость = Не ДанныеАутентификацииПорталаСохранены;
		Элементы.Закрыть.Видимость = Ложь;

	Иначе
		Элементы.ДекорацияПояснение.Заголовок = ТекстПояснения;
		Элементы.ПодключитьИнтернетПоддержку.Видимость = Ложь;
		Элементы.Загрузить.Видимость = Ложь;
		Элементы.Отмена.Видимость = Ложь;
		Элементы.Закрыть.Видимость = Истина;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)

	Если Не ДоступнаЗагрузкаСПортала Тогда
		Отказ = Истина;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодключитьИнтернетПоддержку(Команда = Неопределено)

	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("ИнтернетПоддержкаПользователей") Тогда
		МодульИнтернетПоддержкаПользователейКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль(
			"ИнтернетПоддержкаПользователейКлиент");
		Оповещение = Новый ОписаниеОповещения("ПослеПодключенияИнтернетПоддержки", ЭтотОбъект);
		МодульИнтернетПоддержкаПользователейКлиент.ПодключитьИнтернетПоддержкуПользователей(Оповещение, ЭтотОбъект);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура Загрузить(Команда)

	Если Не ДанныеАутентификацииПорталаСохранены Тогда
		ПодключитьИнтернетПоддержку();
		Возврат;
	КонецЕсли;

	Элементы.Загрузить.Доступность = Ложь;
	Элементы.Страницы.ТекущаяСтраница = Элементы.ДлительнаяОперация;

	ДлительнаяОперация = НачатьОбновлениеКомпонентСПортала();

	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ФормаВладелец = ЭтотОбъект;
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;

	Оповещение = Новый ОписаниеОповещения("ПослеОбновленияКомпонентСПортала", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, Оповещение, ПараметрыОжидания);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПослеПодключенияИнтернетПоддержки(Результат, Параметр) Экспорт

	Если ТипЗнч(Результат) = Тип("Структура") Тогда
		Элементы.ПодключитьИнтернетПоддержку.Видимость = Ложь;
		ДанныеАутентификацииПорталаСохранены = Истина;
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ДанныеАутентификацииПорталаСохранены()

	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей") Тогда
		МодульИнтернетПоддержкаПользователей = ОбщегоНазначения.ОбщийМодуль("ИнтернетПоддержкаПользователей");
		Возврат МодульИнтернетПоддержкаПользователей.ЗаполненыДанныеАутентификацииПользователяИнтернетПоддержки();
	КонецЕсли;

	Возврат Ложь;

КонецФункции

&НаСервере
Функция НачатьОбновлениеКомпонентСПортала()

	ПараметрыПроцедуры = ВнешниеКомпонентыСлужебный.ПараметрыОбновленияКомпонентСПортала();
	ПараметрыПроцедуры.ОбновляемыеКомпоненты = ОбновляемыеКомпоненты.ВыгрузитьЗначения();

	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Обновление внешней компоненты.'");

	Возврат ДлительныеОперации.ВыполнитьВФоне("ВнешниеКомпонентыСлужебный.ОбновитьКомпонентыСПортала",
		ПараметрыПроцедуры, ПараметрыВыполнения);

КонецФункции

// Параметры:
//  Результат - см. ДлительныеОперацииКлиент.НовыйРезультатДлительнойОперации
//  ДополнительныеПараметры - Неопределено
//
&НаКлиенте
Процедура ПослеОбновленияКомпонентСПортала(Результат, ДополнительныеПараметры) Экспорт

	Элементы.Загрузить.Доступность = Истина;
	Элементы.Страницы.ТекущаяСтраница = Элементы.Начальная;
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Если Результат.Статус = "Ошибка" Тогда
		СтандартныеПодсистемыКлиент.ВывестиИнформациюОбОшибке(
			Результат.ИнформацияОбОшибке);
		Возврат;
	КонецЕсли;

	Если Результат.Статус = "Выполнено" Тогда
		
		РезультатОбновления = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
		
		РезультатВыполнения = "";
		Для Каждого КлючИЗначение Из РезультатОбновления.Ошибки Цикл
			РезультатВыполнения = РезультатВыполнения + КлючИЗначение.Значение + Символы.ПС;
		КонецЦикла;
		Для Каждого КлючИЗначение Из РезультатОбновления.Успех Цикл
			РезультатВыполнения = РезультатВыполнения + КлючИЗначение.Значение + Символы.ПС;
		КонецЦикла;
		
		Элементы.Страницы.ТекущаяСтраница = Элементы.Выполнено;
		Элементы.Загрузить.Видимость = Ложь;
		Элементы.Отмена.Видимость = Ложь;
		Элементы.Закрыть.Видимость = Истина;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
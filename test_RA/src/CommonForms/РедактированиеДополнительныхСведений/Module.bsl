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
	
	УстановитьУсловноеОформление();
	
	Если Не ПравоДоступа("Изменение", Метаданные.РегистрыСведений.ДополнительныеСведения) Тогда
		Элементы.ФормаЗаписать.Видимость = Ложь;
		Элементы.ФормаЗаписатьИЗакрыть.Видимость = Ложь;
	КонецЕсли;
	
	Если Не ПравоДоступа("Изменение", Метаданные.Справочники.НаборыДополнительныхРеквизитовИСведений) Тогда
		Элементы.ИзменитьСоставДополнительныхСведений.Видимость = Ложь;
	КонецЕсли;
	
	СсылкаНаОбъект = Параметры.Ссылка;
	
	НаборыСвойств = УправлениеСвойствамиСлужебный.ПолучитьНаборыСвойствОбъекта(Параметры.Ссылка);
	Для каждого СтрокаТаблицы Из НаборыСвойств Цикл
		ДоступныеНаборыСвойств.Добавить(СтрокаТаблицы.Набор);
	КонецЦикла;
	
	ЗаполнитьТаблицуЗначенийСвойств(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ЗаписатьИЗакрытьЗавершение", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_НаборыДополнительныхРеквизитовИСведений" Тогда
		
		Если ДоступныеНаборыСвойств.НайтиПоЗначению(Источник) <> Неопределено Тогда
			ЗаполнитьТаблицуЗначенийСвойств(Ложь);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыТаблицаЗначенийСвойств

&НаКлиенте
Процедура ТаблицаЗначенийСвойствПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗначенийСвойствПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Отказ = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗначенийСвойствПередУдалением(Элемент, Отказ)
	
	Если Элемент.ТекущиеДанные.НомерКартинки = -1 Тогда
		Отказ = Истина;
		Элемент.ТекущиеДанные.Значение = Элемент.ТекущиеДанные.ТипЗначения.ПривестиЗначение(Неопределено);
		Модифицированность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗначенийСвойствПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Элемент.ПодчиненныеЭлементы.ТаблицаЗначенийСвойствЗначение.ОграничениеТипа
		= Элемент.ТекущиеДанные.ТипЗначения;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗначенийСвойствПередНачаломИзменения(Элемент, Отказ)
	Если Элементы.ТаблицаЗначенийСвойств.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Строка = Элементы.ТаблицаЗначенийСвойств.ТекущиеДанные;
	
	ПараметрыВыбораМассив = Новый Массив;
	Если Строка.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектов"))
		Или Строка.ТипЗначения.СодержитТип(Тип("СправочникСсылка.ЗначенияСвойствОбъектовИерархия")) Тогда
		ПараметрыВыбораМассив.Добавить(Новый ПараметрВыбора("Отбор.Владелец",
			?(ЗначениеЗаполнено(Строка.ВладелецДополнительныхЗначений),
				Строка.ВладелецДополнительныхЗначений, Строка.Свойство)));
	КонецЕсли;
	Элементы.ТаблицаЗначенийСвойствЗначение.ПараметрыВыбора = Новый ФиксированныйМассив(ПараметрыВыбораМассив);
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗначенийСвойствВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Поле.Имя <> Элементы.ТаблицаЗначенийСвойствКолонкаВопрос.Имя Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
	Строка = ТаблицаЗначенийСвойств.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Не ЗначениеЗаполнено(Строка.Подсказка) Тогда
		Возврат;
	КонецЕсли;
	
	ТекстЗаголовка = НСтр("ru = 'Подсказка сведения ""%1""'");
	ТекстЗаголовка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстЗаголовка, Строка.Наименование);
	
	ПараметрыВопросаПользователю = СтандартныеПодсистемыКлиент.ПараметрыВопросаПользователю();
	ПараметрыВопросаПользователю.Заголовок = ТекстЗаголовка;
	ПараметрыВопросаПользователю.ПредлагатьБольшеНеЗадаватьЭтотВопрос = Ложь;
	ПараметрыВопросаПользователю.Картинка = БиблиотекаКартинок.ДиалогИнформация;
	
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить("ОК", НСтр("ru = 'ОК'"));
	СтандартныеПодсистемыКлиент.ПоказатьВопросПользователю(Неопределено, Строка.Подсказка, Кнопки, ПараметрыВопросаПользователю);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Записать(Команда)
	
	ЗаписатьЗначенияСвойств();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	ЗаписатьИЗакрытьЗавершение();
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьСоставДополнительныхСведений(Команда)
	
	Если ДоступныеНаборыСвойств.Количество() = 0
	 ИЛИ НЕ ЗначениеЗаполнено(ДоступныеНаборыСвойств[0].Значение) Тогда
		
		ПоказатьПредупреждение(,
			НСтр("ru = 'Не удалось получить наборы дополнительных сведений объекта.
			           |
			           |Возможно у объекта не заполнены необходимые реквизиты.'"));
	Иначе
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("ВидСвойств",
			ПредопределенноеЗначение("Перечисление.ВидыСвойств.ДополнительныеСведения"));
		
		ОткрытьФорму("Справочник.НаборыДополнительныхРеквизитовИСведений.ФормаСписка", ПараметрыФормы);
		
		ПараметрыПерехода = Новый Структура;
		ПараметрыПерехода.Вставить("Набор", ДоступныеНаборыСвойств[0].Значение);
		ПараметрыПерехода.Вставить("Свойство", Неопределено);
		ПараметрыПерехода.Вставить("ЭтоДополнительноеСведение", Истина);
		ПараметрыПерехода.Вставить("ВидСвойств",
			ПредопределенноеЗначение("Перечисление.ВидыСвойств.ДополнительныеСведения"));
		
		Если Элементы.ТаблицаЗначенийСвойств.ТекущиеДанные <> Неопределено Тогда
			ПараметрыПерехода.Вставить("Набор", Элементы.ТаблицаЗначенийСвойств.ТекущиеДанные.Набор);
			ПараметрыПерехода.Вставить("Свойство", Элементы.ТаблицаЗначенийСвойств.ТекущиеДанные.Свойство);
		КонецЕсли;
		
		Оповестить("Переход_НаборыДополнительныхРеквизитовИСведений", ПараметрыПерехода);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаписатьИЗакрытьЗавершение(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	ЗаписатьЗначенияСвойств();
	Модифицированность = Ложь;
	Закрыть();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуЗначенийСвойств(ИзОбработчикаПриСоздании)
	
	Если ИзОбработчикаПриСоздании Тогда
		ЗначенияСвойств = ПрочитатьЗначенияСвойствИзРегистраСведений(Параметры.Ссылка);
	Иначе
		ЗначенияСвойств = ТекущиеЗначенияСвойств();
		ТаблицаЗначенийСвойств.Очистить();
	КонецЕсли;
	
	ПроверяемаяТаблица = "РегистрСведений.ДополнительныеСведения";
	ЗначениеДоступа = Тип("ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения");
	
	Таблица = УправлениеСвойствамиСлужебный.ЗначенияСвойств(
		ЗначенияСвойств, ДоступныеНаборыСвойств, Перечисления.ВидыСвойств.ДополнительныеСведения);
	
	ПроверятьПрава = Не Пользователи.ЭтоПолноправныйПользователь() И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом");
	
	Если ПроверятьПрава Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
		УниверсальноеОграничение = МодульУправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально();
		Если Не УниверсальноеОграничение Тогда
			ПроверяемыеСвойства = Таблица.ВыгрузитьКолонку("Свойство");
			РазрешенныеСвойства = МодульУправлениеДоступомСлужебный.РазрешенныеЗначенияДляДинамическогоСписка(
				ПроверяемаяТаблица, ЗначениеДоступа, ПроверяемыеСвойства, , Истина);
		КонецЕсли;
	КонецЕсли;
	
	Для Каждого СтрокаТаблицы Из Таблица Цикл
		
		Если ПроверятьПрава Тогда
			ПраваДоступаСвойства = ПраваДоступаСвойства(СтрокаТаблицы.Свойство, УниверсальноеОграничение, 
				РазрешенныеСвойства, МодульУправлениеДоступом);
			Если Не ПраваДоступаСвойства.ДоступноДляЧтения Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		НоваяСтрока = ТаблицаЗначенийСвойств.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы);
		
		Если ЗначениеЗаполнено(НоваяСтрока.Подсказка) Тогда
			НоваяСтрока.КолонкаВопрос = "?";
		КонецЕсли;
		
		НоваяСтрока.НомерКартинки = ?(СтрокаТаблицы.Удалено, 0, -1);
		НоваяСтрока.ДоступноДляИзменения = ?(ПроверятьПрава, ПраваДоступаСвойства.ДоступноДляИзменения, Истина);
		
		Если СтрокаТаблицы.Значение = Неопределено
			И ОбщегоНазначения.ОписаниеТипаСостоитИзТипа(СтрокаТаблицы.ТипЗначения, Тип("Булево")) Тогда
			НоваяСтрока.Значение = Ложь;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПраваДоступаСвойства(Свойство, УниверсальноеОграничение, РазрешенныеСвойства, МодульУправлениеДоступом)

	Результат = Новый Структура("ДоступноДляЧтения,ДоступноДляИзменения", Ложь, Ложь);
	Если УниверсальноеОграничение Тогда
		НаборЗаписей = ТестовыйНаборЗаписей(Свойство);
		
		Результат.ДоступноДляЧтения = МодульУправлениеДоступом.ЧтениеРазрешено(НаборЗаписей);
		Результат.ДоступноДляИзменения = МодульУправлениеДоступом.ИзменениеРазрешено(НаборЗаписей);
		Возврат Результат;
	КонецЕсли;

	Если РазрешенныеСвойства <> Неопределено И РазрешенныеСвойства.Найти(Свойство) = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат.ДоступноДляЧтения = Истина;
	НачатьТранзакцию(); // АПК:326 Фиксация транзакции не требуется, т.к. это проверка прав на запись.
	Попытка
		НаборЗаписей = ТестовыйНаборЗаписей(Свойство);
		НаборЗаписей.ОбменДанными.Загрузка = Истина;
		НаборЗаписей.Записать(Истина);

		Результат.ДоступноДляИзменения = Истина;
		
		ОтменитьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
	КонецПопытки;
	Возврат Результат;

КонецФункции

&НаСервере
Функция ТестовыйНаборЗаписей(Свойство)
	НаборЗаписей = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Объект.Установить(Параметры.Ссылка);
	НаборЗаписей.Отбор.Свойство.Установить(Свойство);
	
	Запись = НаборЗаписей.Добавить();
	Запись.Свойство = Свойство;
	Запись.Объект = Параметры.Ссылка;
	
	Возврат НаборЗаписей;
КонецФункции

&НаКлиенте
Процедура ЗаписатьЗначенияСвойств()
	
	ЗначенияСвойств = Новый Массив;
	Для Каждого СтрокаТаблицы Из ТаблицаЗначенийСвойств Цикл
		Значение = Новый Структура("Свойство, Значение", СтрокаТаблицы.Свойство, СтрокаТаблицы.Значение);
		ЗначенияСвойств.Добавить(Значение);
	КонецЦикла;
	
	Если ЗначенияСвойств.Количество() > 0 Тогда
		ЗаписатьНаборСвойствВРегистр(СсылкаНаОбъект, ЗначенияСвойств);
	КонецЕсли;
	
	Модифицированность = Ложь;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаписатьНаборСвойствВРегистр(Знач Ссылка, Знач ЗначенияСвойств)
	
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ДополнительныеСведения");
		ЭлементБлокировки.УстановитьЗначение("Объект", Ссылка);
		Блокировка.Заблокировать();
		
		Набор = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
		Набор.Отбор.Объект.Установить(Ссылка);
		Набор.Прочитать();
		ТекущиеЗначения = Набор.Выгрузить();
		Для Каждого СтрокаТаблицы Из ЗначенияСвойств Цикл
			Запись = ТекущиеЗначения.Найти(СтрокаТаблицы.Свойство, "Свойство");
			Если Запись = Неопределено Тогда
				Запись = ТекущиеЗначения.Добавить();
				Запись.Свойство = СтрокаТаблицы.Свойство;
				Запись.Значение = СтрокаТаблицы.Значение;
				Запись.Объект   = Ссылка;
			КонецЕсли;
			Запись.Значение = СтрокаТаблицы.Значение;
			
			Если Не ЗначениеЗаполнено(Запись.Значение)
				Или Запись.Значение = Ложь Тогда
				ТекущиеЗначения.Удалить(Запись);
			КонецЕсли;
		КонецЦикла;
		Набор.Загрузить(ТекущиеЗначения);
		Набор.Записать();
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
	КонецПопытки;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПрочитатьЗначенияСвойствИзРегистраСведений(Ссылка)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДополнительныеСведения.Свойство,
	|	ДополнительныеСведения.Значение
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
	|ГДЕ
	|	ДополнительныеСведения.Объект = &Объект";
	Запрос.УстановитьПараметр("Объект", Ссылка);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

&НаСервере
Функция ТекущиеЗначенияСвойств()
	
	ЗначенияСвойств = Новый ТаблицаЗначений;
	ЗначенияСвойств.Колонки.Добавить("Свойство");
	ЗначенияСвойств.Колонки.Добавить("Значение");
	
	Для каждого СтрокаТаблицы Из ТаблицаЗначенийСвойств Цикл
		
		Если ЗначениеЗаполнено(СтрокаТаблицы.Значение) И (СтрокаТаблицы.Значение <> Ложь) Тогда
			НоваяСтрока = ЗначенияСвойств.Добавить();
			НоваяСтрока.Свойство = СтрокаТаблицы.Свойство;
			НоваяСтрока.Значение = СтрокаТаблицы.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ЗначенияСвойств;
	
КонецФункции

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	//
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТаблицаЗначенийСвойствЗначение.Имя);
	
	// Формат даты - время.
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ТаблицаЗначенийСвойств.ТипЗначения");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Новый ОписаниеТипов("Дата",,, Новый КвалификаторыДаты(ЧастиДаты.Время));
	Элемент.Оформление.УстановитьЗначениеПараметра("Формат", "ДЛФ=T");
	
	//
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТаблицаЗначенийСвойствЗначение.Имя);
	
	// Формат даты - дата.
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ТаблицаЗначенийСвойств.ТипЗначения");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Новый ОписаниеТипов("Дата",,, Новый КвалификаторыДаты(ЧастиДаты.Дата));
	Элемент.Оформление.УстановитьЗначениеПараметра("Формат", "ДЛФ=D");
	
	//
	Элемент = УсловноеОформление.Элементы.Добавить();
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТаблицаЗначенийСвойствЗначение.Имя);
	
	// Доступность поля, если нет прав на изменение.
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ТаблицаЗначенийСвойств.ДоступноДляИзменения");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
	Элемент.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);
	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", ЦветаСтиля.ТекстЗапрещеннойЯчейкиЦвет);
	
КонецПроцедуры

#КонецОбласти

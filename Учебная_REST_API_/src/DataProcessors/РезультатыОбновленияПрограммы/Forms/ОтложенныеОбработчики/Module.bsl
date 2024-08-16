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
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ВремяНачалаОтложенногоОбновления = СведенияОбОбновлении.ВремяНачалаОтложенногоОбновления;
	ВремяОкончанияОтложенногоОбновления = СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления;
	НомерТекущегоСеанса = СведенияОбОбновлении.НомерСеанса;
	ИБФайловая = ОбщегоНазначения.ИнформационнаяБазаФайловая();
	
	ПолноправныйПользователь = Пользователи.ЭтоПолноправныйПользователь(, Ложь);
	Если Не ПолноправныйПользователь Тогда
		Элементы.ГруппаПовторныйЗапуск.Видимость = Ложь;
		Элементы.Возобновить.Видимость             = Ложь;
		Элементы.Остановить.Видимость         = Ложь;
		Элементы.ГруппаПорядок.Видимость         = Ложь;
		Элементы.КонтекстноеМенюПриостановить.Видимость = Ложь;
		Элементы.КонтекстноеМенюЗапустить.Видимость     = Ложь;
		Элементы.ОтложенныеОбработчикиКонтекстноеМенюПорядок.Видимость = Ложь;
	ИначеЕсли ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
		Элементы.ОтложенныеОбработчикиКонтекстноеМенюПорядок.Видимость = Ложь;
		Элементы.ГруппаПорядок.Видимость         = Ложь;
	КонецЕсли;
	
	Если Не ИБФайловая Тогда
		ОбновлениеВыполняется = (СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено);
	КонецЕсли;
	
	Если Не ОбщегоНазначения.РежимОтладки()
		Или СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Истина Тогда
		Элементы.ЗапуститьПроцедуру.Видимость = Ложь;
		Элементы.КонтекстноеМенюЗапуститьВыделенный.Видимость = Ложь;
	КонецЕсли;
	
	Если Не ПравоДоступа("Просмотр", Метаданные.Обработки.ЖурналРегистрации) Тогда
		Элементы.ГиперссылкаОтложенноеОбновление.Видимость = Ложь;
	КонецЕсли;
	
	Статус = "ВсеПроцедуры";
	
	СформироватьТаблицуОтложенныхОбработчиков(, Истина);
	
	Элементы.ГиперссылкаПрогрессОбновления.Видимость = ПараллельныйРежимИспользуется;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Верх;
		Элементы.ГруппаСодержимое.Отображение = ОтображениеОбычнойГруппы.ОбычноеВыделение;
		Элементы.Приоритет.Видимость = Ложь;
		Элементы.Номер.Видимость = Ложь;
		Элементы.ОтложенныеОбработчикиИнтервалВыполнения.Видимость = Ложь;
		Элементы.ОтложенныеОбработчикиДлительностьВыполнения.Видимость = Ложь;
	КонецЕсли;
	
	ЗначениеОшибка      = Строка(Перечисления.СтатусыОбработчиковОбновления.Ошибка);
	ЗначениеВыполняется = Строка(Перечисления.СтатусыОбработчиковОбновления.Выполняется);
	ЗначениеВыполнен    = Строка(Перечисления.СтатусыОбработчиковОбновления.Выполнен);
	Элементы.Статус.СписокВыбора.Добавить(ЗначениеОшибка, ЗначениеОшибка);
	Элементы.Статус.СписокВыбора.Добавить(ЗначениеВыполняется, ЗначениеВыполняется);
	Элементы.Статус.СписокВыбора.Добавить(ЗначениеВыполнен, ЗначениеВыполнен);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОтложенныеОбработчикиПриАктивизацииСтроки(Элемент)
	Если Элемент.ТекущиеДанные = Неопределено
		Или Не ПолноправныйПользователь Тогда
		Возврат;
	КонецЕсли;
	
	Если Элемент.ТекущиеДанные.Статус = ПредопределенноеЗначение("Перечисление.СтатусыОбработчиковОбновления.Выполняется") Тогда
		Элементы.КонтекстноеМенюЗапустить.Доступность = Ложь;
		Элементы.КонтекстноеМенюПриостановить.Доступность = Истина;
		Элементы.Возобновить.Доступность = Ложь;
		Элементы.Остановить.Доступность = Истина;
	ИначеЕсли Элемент.ТекущиеДанные.Статус = ПредопределенноеЗначение("Перечисление.СтатусыОбработчиковОбновления.Приостановлен") Тогда
		Элементы.КонтекстноеМенюЗапустить.Доступность = Истина;
		Элементы.КонтекстноеМенюПриостановить.Доступность = Ложь;
		Элементы.Возобновить.Доступность = Истина;
		Элементы.Остановить.Доступность = Ложь;
	Иначе
		Элементы.КонтекстноеМенюЗапустить.Доступность = Ложь;
		Элементы.КонтекстноеМенюПриостановить.Доступность = Ложь;
		Элементы.Возобновить.Доступность = Ложь;
		Элементы.Остановить.Доступность = Ложь;
	КонецЕсли;
	
	Если Не ОбновлениеВыполняется
		И Элемент.ТекущиеДанные.Статус <> ПредопределенноеЗначение("Перечисление.СтатусыОбработчиковОбновления.Выполнен") Тогда
		Элементы.ЗапуститьПроцедуру.Доступность = Истина;
		Элементы.КонтекстноеМенюЗапуститьВыделенный.Доступность = Истина;
	Иначе
		Элементы.ЗапуститьПроцедуру.Доступность = Ложь;
		Элементы.КонтекстноеМенюЗапуститьВыделенный.Доступность = Ложь;
	КонецЕсли;
	
	ОбновитьСтатусыКомандПриоритета(Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ГиперссылкаОбработчикиОбновленияНажатие(Элемент)
	ОтборСписка = Новый Структура;
	ОтборСписка.Вставить("РежимВыполнения", ПредопределенноеЗначение("Перечисление.РежимыВыполненияОбработчиков.Отложенно"));
	
	ОткрытьФорму("РегистрСведений.ОбработчикиОбновления.ФормаСписка", ОтборСписка);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыОтложенныеОбработчики

&НаКлиенте
Процедура ОтложенныеОбработчикиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	Если Элемент.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяОбработчика = Элемент.ТекущиеДанные.Идентификатор;
	
	Отбор = Новый Структура("ИмяОбработчика",ИмяОбработчика);
	
	ТипЗначения = Тип("РегистрСведенийКлючЗаписи.ОбработчикиОбновления");
	ПараметрыЗаписи = Новый Массив(1);
	ПараметрыЗаписи[0] = Отбор;
	
	КлючЗаписи = Новый(ТипЗначения, ПараметрыЗаписи);
	ПоказатьЗначение(Неопределено, КлючЗаписи);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗакрытьФорму(Команда)
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьПовторно(Команда)
	Оповестить("ОтложенноеОбновление");
	Закрыть();
КонецПроцедуры

&НаКлиенте
Процедура ГиперссылкаОтложенноеОбновлениеНажатие(Элемент)
	
	ПолучитьСведенияОбОбновлении();
	Если ЗначениеЗаполнено(ВремяНачалаОтложенногоОбновления) Тогда
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("ДатаНачала", ВремяНачалаОтложенногоОбновления);
		Если ЗначениеЗаполнено(ВремяОкончанияОтложенногоОбновления) Тогда
			ПараметрыФормы.Вставить("ДатаОкончания", ВремяОкончанияОтложенногоОбновления);
		КонецЕсли;
		ПараметрыФормы.Вставить("Сеанс", НомерТекущегоСеанса);
		
		ОткрытьФорму("Обработка.ЖурналРегистрации.Форма.ЖурналРегистрации", ПараметрыФормы);
	Иначе
		ТекстПредупреждения = НСтр("ru = 'Обработка данных еще не выполнялась.'");
		ПоказатьПредупреждение(,ТекстПредупреждения);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ГиперссылкаПрогрессОбновленияНажатие(Элемент)
	ОткрытьФорму("Отчет.ПрогрессОтложенногоОбновления.Форма");
КонецПроцедуры

&НаКлиенте
Процедура СтатусПриИзменении(Элемент)
	
	Если Статус = "ЖелательноБыстрее" Тогда
		ОтборСтрокТаблицы = Новый Структура;
		ОтборСтрокТаблицы.Вставить("Приоритет", БиблиотекаКартинок.ВосклицательныйЗнакКрасный);
		Элементы.ОтложенныеОбработчики.ОтборСтрок = Новый ФиксированнаяСтруктура(ОтборСтрокТаблицы);
	ИначеЕсли Статус = "ВсеПроцедуры" Тогда
		Элементы.ОтложенныеОбработчики.ОтборСтрок = Новый ФиксированнаяСтруктура;
	Иначе
		ОтборСтрокТаблицы = Новый Структура;
		ОтборСтрокТаблицы.Вставить("Статус", Статус);
		Элементы.ОтложенныеОбработчики.ОтборСтрок = Новый ФиксированнаяСтруктура(ОтборСтрокТаблицы);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СтрокаПоискаПриИзменении(Элемент)
	ОтложенныеОбработчики.Очистить();
	СформироватьТаблицуОтложенныхОбработчиков(, Истина);
КонецПроцедуры

&НаКлиенте
Процедура Приостановить(Команда)
	ТекущиеДанные = Элементы.ОтложенныеОбработчики.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПроцедураОбновления = ТекущиеДанные.Идентификатор;
	
	ТекстВопроса = НСтр("ru = 'Остановка дополнительных процедур обработки данных
		|может привести к нестабильной работе или неработоспособности приложения.
		|Выполнять отключение рекомендуется в случае обнаружения ошибки
		|в процедуре обработки данных и только после консультации со службой поддержки,
		|т.к. процедуры отработки данных могут зависеть друг от друга.'");
	КнопкиВопроса = Новый СписокЗначений;
	КнопкиВопроса.Добавить("Да", "Остановить");
	КнопкиВопроса.Добавить("Нет", "Отмена");
	
	Оповещение = Новый ОписаниеОповещения("ПриостановитьВыполнениеОтложенногоОбработчика", ЭтотОбъект, ПроцедураОбновления);
	ПоказатьВопрос(Оповещение, ТекстВопроса, КнопкиВопроса);
	
КонецПроцедуры

&НаКлиенте
Процедура Запустить(Команда)
	ТекущиеДанные = Элементы.ОтложенныеОбработчики.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПроцедураОбновления = ТекущиеДанные.Идентификатор;
	ЗапуститьВыполнениеОтложенногоОбработчика(ПроцедураОбновления);
	Оповестить("ОтложенноеОбновление");
	ПодключитьОбработчикОжидания("ОбновитьТаблицуОбработчиков", 1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	ОбновитьСтатусыОбработчиков(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ВПлановомПорядке(Команда)
	
	ТекущаяСтрока = Элементы.ОтложенныеОбработчики.ТекущиеДанные;
	Если ТекущаяСтрока = Неопределено
		Или Элементы.ВПлановомПорядке.Пометка Тогда
		Возврат;
	КонецЕсли;
	
	ИзменитьПриоритет("ПриоритетВПлановомПорядке", ТекущаяСтрока.Идентификатор, ТекущаяСтрока.Очередь);
	ТекущаяСтрока.КартинкаПриоритет = БиблиотекаКартинок.ВосклицательныйЗнакСерый;
	ТекущаяСтрока.Приоритет = "Неопределено";
	ОбновитьСтатусыКомандПриоритета(Элементы.ОтложенныеОбработчики);
	
КонецПроцедуры

&НаКлиенте
Процедура ЖелательноБыстрее(Команда)
	ТекущаяСтрока = Элементы.ОтложенныеОбработчики.ТекущиеДанные;
	Если ТекущаяСтрока = Неопределено
		Или Элементы.ЖелательноБыстрее.Пометка Тогда
		Возврат;
	КонецЕсли;
	
	ИзменитьПриоритет("ПриоритетЖелательноБыстрее", ТекущаяСтрока.Идентификатор, ТекущаяСтрока.Очередь);
	ТекущаяСтрока.КартинкаПриоритет = БиблиотекаКартинок.ВосклицательныйЗнакСерый;
	ТекущаяСтрока.Приоритет = "Неопределено";
	ОбновитьСтатусыКомандПриоритета(Элементы.ОтложенныеОбработчики);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьВыделенный(Команда)
	Если Элементы.ОтложенныеОбработчики.ТекущиеДанные = Неопределено
		Или Не ПолноправныйПользователь Тогда
		Возврат;
	КонецЕсли;
	
	ЗапуститьВыделеннуюПроцедуруДляОтладки(Элементы.ОтложенныеОбработчики.ТекущиеДанные.Идентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьНаличиеИсправлений(Команда)
	Результат = ДоступныеИсправленияНаСервере();
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПроверитьДоступныеИсправленияПродолжение", ЭтотОбъект, Результат);
	ОбновлениеИнформационнойБазыКлиент.ОбработатьРезультатРучнойПроверкиДоступныхПатчей(Результат, ОписаниеОповещения);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗапуститьВыделеннуюПроцедуруДляОтладки(ИмяОбработчика)
	
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено;
	СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления = Неопределено;
	ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
	
	НаборЗаписей = РегистрыСведений.ОбработчикиОбновления.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ИмяОбработчика.Установить(ИмяОбработчика);
	НаборЗаписей.Прочитать();
	
	Обработчик = НаборЗаписей[0];
	Обработчик.Статус = Перечисления.СтатусыОбработчиковОбновления.НеВыполнялся;
	Обработчик.СтатистикаВыполнения = Новый ХранилищеЗначения(Новый Соответствие);
	
	// АПК:1327-выкл нет конкурентной работы с регистром
	НаборЗаписей.Записать();
	// АПК:1327-вкл
	ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОтложенноеОбновлениеСейчас(Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСтатусыКомандПриоритета(Элемент)
	
	Если Элемент.ТекущиеДанные.Приоритет = "ЖелательноБыстрее" Тогда
		Элементы.ЖелательноБыстрее.Пометка = Истина;
		Элементы.ЖелательноБыстрееКонтекстноеМеню.Пометка = Истина;
		Элементы.ВПлановомПорядке.Пометка = Ложь;
		Элементы.ВПлановомПорядкеКонтекстноеМеню.Пометка = Ложь;
	Иначе
		Элементы.ВПлановомПорядке.Пометка = Истина;
		Элементы.ВПлановомПорядкеКонтекстноеМеню.Пометка = Истина;
		Элементы.ЖелательноБыстрее.Пометка = Ложь;
		Элементы.ЖелательноБыстрееКонтекстноеМеню.Пометка = Ложь;
	КонецЕсли;
	
	Если Элемент.ТекущиеДанные.Приоритет = "Неопределено"
		Или Элемент.ТекущиеДанные.Статус = ПредопределенноеЗначение("Перечисление.СтатусыОбработчиковОбновления.Выполнен") Тогда
		Элементы.ВПлановомПорядке.Доступность = Ложь;
		Элементы.ВПлановомПорядкеКонтекстноеМеню.Доступность = Ложь;
		Элементы.ЖелательноБыстрее.Доступность = Ложь;
		Элементы.ЖелательноБыстрееКонтекстноеМеню.Доступность = Ложь;
	Иначе
		Элементы.ВПлановомПорядке.Доступность = Истина;
		Элементы.ВПлановомПорядкеКонтекстноеМеню.Доступность = Истина;
		Элементы.ЖелательноБыстрее.Доступность = Истина;
		Элементы.ЖелательноБыстрееКонтекстноеМеню.Доступность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриостановитьВыполнениеОтложенногоОбработчика(Результат, ПроцедураОбновления) Экспорт
	Если Результат = "Нет" Тогда
		Возврат;
	КонецЕсли;
	
	ПриостановитьВыполнениеОтложенногоОбработчикаНаСервере(ПроцедураОбновления);
КонецПроцедуры

&НаСервере
Процедура ПриостановитьВыполнениеОтложенногоОбработчикаНаСервере(ПроцедураОбновления)
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		Блокировка.Добавить("Константа.СведенияОбОбновленииИБ");
		Блокировка.Заблокировать();
		
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		Если СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Свойство("ОстановитьОбработчики")
			И ТипЗнч(СведенияОбОбновлении.УправлениеОтложеннымОбновлением.ОстановитьОбработчики) = Тип("Массив") Тогда
			ОстановленныеОбработчики = СведенияОбОбновлении.УправлениеОтложеннымОбновлением.ОстановитьОбработчики;
			Если ОстановленныеОбработчики.Найти(ПроцедураОбновления) = Неопределено Тогда
				ОстановленныеОбработчики.Добавить(ПроцедураОбновления);
			КонецЕсли;
		Иначе
			ОстановленныеОбработчики = Новый Массив;
			ОстановленныеОбработчики.Добавить(ПроцедураОбновления);
			СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Вставить("ОстановитьОбработчики", ОстановленныеОбработчики);
		КонецЕсли;
		
		ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Процедура ЗапуститьВыполнениеОтложенногоОбработчика(ПроцедураОбновления)
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		Блокировка.Добавить("Константа.СведенияОбОбновленииИБ");
		Блокировка.Заблокировать();
		
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		Если СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Свойство("ЗапуститьОбработчики")
			И ТипЗнч(СведенияОбОбновлении.УправлениеОтложеннымОбновлением.ЗапуститьОбработчики) = Тип("Массив") Тогда
			ЗапущенныеОбработчики = СведенияОбОбновлении.УправлениеОтложеннымОбновлением.ЗапуститьОбработчики;
			Если ЗапущенныеОбработчики.Найти(ПроцедураОбновления) = Неопределено Тогда
				ЗапущенныеОбработчики.Добавить(ПроцедураОбновления);
			КонецЕсли;
		Иначе
			ЗапущенныеОбработчики = Новый Массив;
			ЗапущенныеОбработчики.Добавить(ПроцедураОбновления);
			СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Вставить("ЗапуститьОбработчики", ЗапущенныеОбработчики);
		КонецЕсли;
		
		ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьТаблицуОбработчиков()
	ОбновитьСтатусыОбработчиков(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСтатусыОбработчиков(ПоКоманде)
	
	ВыполненыВсеОбработчики = Истина;
	СформироватьТаблицуОтложенныхОбработчиков(ВыполненыВсеОбработчики);
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьСведенияОбОбновлении()
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ВремяНачалаОтложенногоОбновления = СведенияОбОбновлении.ВремяНачалаОтложенногоОбновления;
	ВремяОкончанияОтложенногоОбновления = СведенияОбОбновлении.ВремяОкончаниеОтложенногоОбновления;
	НомерТекущегоСеанса = СведенияОбОбновлении.НомерСеанса;
КонецПроцедуры

&НаСервере
Процедура СформироватьТаблицуОтложенныхОбработчиков(ВыполненыВсеОбработчики = Истина, НачальноеЗаполнение = Ложь)
	
	ОбработчикиНеВыполнялись = Истина;
	СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
	ВыполняетсяИзменениеПриоритета = СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Свойство("ПриоритетЖелательноБыстрее")
		Или СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Свойство("ПриоритетВПлановомПорядке");
	ОбновлениеВыполняется = (СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно = Неопределено);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("РежимВыполнения", Перечисления.РежимыВыполненияОбработчиков.Отложенно);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОбработчикиОбновления.ИмяОбработчика КАК ИмяОбработчика,
	|	ОбработчикиОбновления.Статус КАК Статус,
	|	ОбработчикиОбновления.Версия КАК Версия,
	|	ОбработчикиОбновления.ИмяБиблиотеки КАК ИмяБиблиотеки,
	|	ОбработчикиОбновления.ДлительностьОбработки КАК ДлительностьОбработки,
	|	ОбработчикиОбновления.РежимВыполнения КАК РежимВыполнения,
	|	ОбработчикиОбновления.ВерсияРегистрации КАК ВерсияРегистрации,
	|	ОбработчикиОбновления.ВерсияПорядок КАК ВерсияПорядок,
	|	ОбработчикиОбновления.Идентификатор КАК Идентификатор,
	|	ОбработчикиОбновления.ЧислоПопыток КАК ЧислоПопыток,
	|	ОбработчикиОбновления.ИнформацияОбОшибке КАК ИнформацияОбОшибке,
	|	ОбработчикиОбновления.Комментарий КАК Комментарий,
	|	ОбработчикиОбновления.Приоритет КАК Приоритет,
	|	ОбработчикиОбновления.ПроцедураПроверки КАК ПроцедураПроверки,
	|	ОбработчикиОбновления.ПроцедураЗаполненияДанныхОбновления КАК ПроцедураЗаполненияДанныхОбновления,
	|	ОбработчикиОбновления.ОчередьОтложеннойОбработки КАК ОчередьОтложеннойОбработки,
	|	ОбработчикиОбновления.ЗапускатьТолькоВГлавномУзле КАК ЗапускатьТолькоВГлавномУзле,
	|	ОбработчикиОбновления.ЗапускатьИВПодчиненномУзлеРИБСФильтрами КАК ЗапускатьИВПодчиненномУзлеРИБСФильтрами,
	|	ОбработчикиОбновления.Многопоточный КАК Многопоточный,
	|	ОбработчикиОбновления.ОбработкаПорцииЗавершена КАК ОбработкаПорцииЗавершена,
	|	ОбработчикиОбновления.ГруппаОбновления КАК ГруппаОбновления,
	|	ОбработчикиОбновления.ИтерацияЗапуска КАК ИтерацияЗапуска,
	|	ОбработчикиОбновления.РежимВыполненияОтложенногоОбработчика КАК РежимВыполненияОтложенногоОбработчика,
	|	ОбработчикиОбновления.ОбрабатываемыеДанные КАК ОбрабатываемыеДанные,
	|	ОбработчикиОбновления.СтатистикаВыполнения КАК СтатистикаВыполнения
	|ИЗ
	|	РегистрСведений.ОбработчикиОбновления КАК ОбработчикиОбновления
	|ГДЕ
	|	ОбработчикиОбновления.РежимВыполнения = &РежимВыполнения";
	Обработчики = Запрос.Выполнить().Выгрузить();
	Для Каждого Обработчик Из Обработчики Цикл
		Если Не ПараллельныйРежимИспользуется Тогда
			ПараллельныйРежимИспользуется = (Обработчик.РежимВыполненияОтложенногоОбработчика = Перечисления.РежимыВыполненияОтложенныхОбработчиков.Параллельно);
		КонецЕсли;
		
		Если Не ПустаяСтрока(СтрокаПоиска) Тогда
			Если СтрНайти(ВРег(Обработчик.Комментарий), ВРег(СтрокаПоиска)) = 0
				И СтрНайти(ВРег(Обработчик.ИмяОбработчика), ВРег(СтрокаПоиска)) = 0 Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		ДобавитьОтложенныйОбработчик(Обработчик, ОбработчикиНеВыполнялись, ВыполненыВсеОбработчики, НачальноеЗаполнение, ВыполняетсяИзменениеПриоритета);
		
		Если Обработчик.РежимВыполненияОтложенногоОбработчика <> Перечисления.РежимыВыполненияОтложенныхОбработчиков.Параллельно Тогда
			Продолжить;
		КонецЕсли;
		
		ИнформацияПоОбработчику = Обработчик.ОбрабатываемыеДанные.Получить();
		Если ИнформацияПоОбработчику = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ОбъектыОбработчика = Новый Соответствие;
		ТаблицаОбрабатываемыеДанные = РеквизитФормыВЗначение("ОбрабатываемыеДанные");
		СписокОбъектов = Новый СписокЗначений;
		ОбрабатываемыеОбъектыПООчередям = ИнформацияПоОбработчику.ДанныеОбработчика;
		Для Каждого ОбрабатываемыйОбъект Из ОбрабатываемыеОбъектыПООчередям Цикл
			ИмяОбъекта = ОбрабатываемыйОбъект.Ключ;
			Очередь    = ОбрабатываемыйОбъект.Значение.Очередь;
			СтрокаТаблицы = ТаблицаОбрабатываемыеДанные.Добавить();
			СтрокаТаблицы.Обработчик = Обработчик.ИмяОбработчика;
			СтрокаТаблицы.ИмяОбъекта = ИмяОбъекта;
			СтрокаТаблицы.Очередь    = Очередь;
			
			СписокОбъектов.Добавить(ИмяОбъекта);
		КонецЦикла;
		ОбъектыОбработчика.Вставить(Обработчик.ИмяОбработчика, СписокОбъектов);
		
		ОбъектыОбработчикаАдрес = ПоместитьВоВременноеХранилище(ОбъектыОбработчика, УникальныйИдентификатор);
		ЗначениеВРеквизитФормы(ТаблицаОбрабатываемыеДанные, "ОбрабатываемыеДанные");
	КонецЦикла;
	
	Если Статус = "ЖелательноБыстрее" Тогда
		ОтборСтрокТаблицы = Новый Структура;
		ОтборСтрокТаблицы.Вставить("Приоритет", БиблиотекаКартинок.ВосклицательныйЗнакКрасный);
		Элементы.ОтложенныеОбработчики.ОтборСтрок = Новый ФиксированнаяСтруктура(ОтборСтрокТаблицы);
	ИначеЕсли Статус <> "ВсеПроцедуры" Тогда
		ОтборСтрокТаблицы = Новый Структура;
		ОтборСтрокТаблицы.Вставить("Статус", Статус);
		Элементы.ОтложенныеОбработчики.ОтборСтрок = Новый ФиксированнаяСтруктура(ОтборСтрокТаблицы);
	КонецЕсли;
	
	Если ВыполненыВсеОбработчики Или ОбновлениеВыполняется Тогда
		Элементы.ГруппаПовторныйЗапуск.Видимость = Ложь;
	КонецЕсли;
	
	Если ОбработчикиНеВыполнялись Тогда
		Элементы.ТекстПояснения.Заголовок = НСтр("ru = 'Рекомендуется Возобновить невыполненные процедуры обработки данных.'");
	Иначе
		Элементы.ТекстПояснения.Заголовок = НСтр("ru = 'Невыполненные процедуры рекомендуется Возобновить повторно.'");
	КонецЕсли;
	
	НомерЭлемента = 1;
	Для Каждого СтрокаТаблицы Из ОтложенныеОбработчики Цикл
		СтрокаТаблицы.Номер = НомерЭлемента;
		НомерЭлемента = НомерЭлемента + 1;
	КонецЦикла;
	
	Элементы.ОбновлениеВыполняется.Видимость = ОбновлениеВыполняется;
	
	Элементы.ПроверитьНаличиеИсправлений.Видимость = СведенияОбОбновлении.ОтложенноеОбновлениеЗавершеноУспешно <> Истина
		И ОбновлениеИнформационнойБазыСлужебный.ДоступнаРучнаяПроверкаНаличияИсправления();
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьОтложенныйОбработчик(СтрокаОбработчика, ОбработчикиНеВыполнялись, ВыполненыВсеОбработчики, НачальноеЗаполнение, ВыполняетсяИзменениеПриоритета)
	
	Если НачальноеЗаполнение Тогда
		СтрокаСписка = ОтложенныеОбработчики.Добавить();
	Иначе
		ПараметрыОтбора = Новый Структура;
		ПараметрыОтбора.Вставить("Идентификатор", СтрокаОбработчика.ИмяОбработчика);
		СтрокаСписка = ОтложенныеОбработчики.НайтиСтроки(ПараметрыОтбора)[0];
	КонецЕсли;
	
	СтатистикаВыполнения = СтрокаОбработчика.СтатистикаВыполнения.Получить();
	
	НачалоОбработкиДанных = СтатистикаВыполнения["НачалоОбработкиДанных"];
	ЗавершениеОбработкиДанных = СтатистикаВыполнения["ЗавершениеОбработкиДанных"];
	ДлительностьВыполнения = СтатистикаВыполнения["ДлительностьВыполнения"];
	ПрогрессВыполнения = СтатистикаВыполнения["ПрогрессВыполнения"];
	
	МаксимальнаяДлительность = 0;
	Если ЗначениеЗаполнено(ЗавершениеОбработкиДанных) И ЗначениеЗаполнено(НачалоОбработкиДанных) Тогда
		МаксимальнаяДлительность = (ЗавершениеОбработкиДанных - НачалоОбработкиДанных) * 1000;
	КонецЕсли;
	
	Прогресс = Неопределено;
	Если ПрогрессВыполнения <> Неопределено
		И ПрогрессВыполнения.ВсегоОбъектов <> 0 
		И ПрогрессВыполнения.ОбработаноОбъектов <> 0 Тогда
		Прогресс = ПрогрессВыполнения.ОбработаноОбъектов / ПрогрессВыполнения.ВсегоОбъектов * 100;
		Прогресс = Цел(Прогресс);
		Прогресс = ?(Прогресс > 100, 99, Прогресс);
	КонецЕсли;
	
	СтрокаСписка.Очередь       = СтрокаОбработчика.ОчередьОтложеннойОбработки;
	СтрокаСписка.Идентификатор = СтрокаОбработчика.ИмяОбработчика;
	СтрокаСписка.Обработчик    = ?(ЗначениеЗаполнено(СтрокаОбработчика.Комментарий),
		                           СтрокаОбработчика.Комментарий,
		                           ПроцедураОбработкиДанных(СтрокаОбработчика.ИмяОбработчика));
	
	ШаблонИнтервалВыполнения =
		НСтр("ru = '%1 -
		           |%2'");
	
	ШаблонИнформацияОПроцедуреОбновления = НСтр("ru = 'Процедура ""%1"" обработки данных %2.'");
	
	СтрокаСписка.Статус = СтрокаОбработчика.Статус;
	Если СтрокаОбработчика.Статус = Перечисления.СтатусыОбработчиковОбновления.Выполнен Тогда
		
		ОбработчикиНеВыполнялись = Ложь;
		ПредставлениеСтатусаВыполнения = НСтр("ru = 'завершилась успешно'");
		СтрокаСписка.СтатусПредставление = НСтр("ru = 'Выполнено'");
		СтрокаСписка.ДлительностьВыполнения = ДлительностьВыполненияПроцедурыОбновления(ДлительностьВыполнения, МаксимальнаяДлительность);
	ИначеЕсли СтрокаОбработчика.Статус = Перечисления.СтатусыОбработчиковОбновления.Выполняется Тогда
		
		ОбработчикиНеВыполнялись = Ложь;
		ВыполненыВсеОбработчики        = Ложь;
		ПредставлениеСтатусаВыполнения = НСтр("ru = 'в данный момент выполняется'");
		Если Прогресс <> Неопределено Тогда
			ШаблонСтатус = НСтр("ru = 'Выполняется (%1%)'");
			СтрокаСписка.СтатусПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСтатус, Прогресс)
		Иначе
			СтрокаСписка.СтатусПредставление = НСтр("ru = 'Выполняется'");
		КонецЕсли;
	ИначеЕсли СтрокаОбработчика.Статус = Перечисления.СтатусыОбработчиковОбновления.Ошибка Тогда
		
		ОбработчикиНеВыполнялись = Ложь;
		ВыполненыВсеОбработчики        = Ложь;
		ПредставлениеСтатусаВыполнения = НСтр("ru = 'Процедура ""%1"" обработки данных завершилась с ошибкой:'") + Символы.ПС + Символы.ПС;
		ПредставлениеСтатусаВыполнения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ПредставлениеСтатусаВыполнения, СтрокаОбработчика.ИмяОбработчика);
		СтрокаСписка.ИнформацияОПроцедуреОбновления = ПредставлениеСтатусаВыполнения + СтрокаОбработчика.ИнформацияОбОшибке;
		СтрокаСписка.СтатусПредставление = НСтр("ru = 'Ошибка'");
		СтрокаСписка.ДлительностьВыполнения = ДлительностьВыполненияПроцедурыОбновления(ДлительностьВыполнения, МаксимальнаяДлительность);
	ИначеЕсли СтрокаОбработчика.Статус = Перечисления.СтатусыОбработчиковОбновления.Приостановлен Тогда
		
		ОбработчикиНеВыполнялись = Ложь;
		ВыполненыВсеОбработчики        = Ложь;
		ПредставлениеСтатусаВыполнения = НСтр("ru = 'остановлена администратором'");
		СтрокаСписка.СтатусПредставление = НСтр("ru = 'Остановлено'");
	Иначе
		
		ВыполненыВсеОбработчики        = Ложь;
		ПредставлениеСтатусаВыполнения = НСтр("ru = 'еще не выполнялась'");
		СтрокаСписка.СтатусПредставление = НСтр("ru = 'Не выполнялась'");
	КонецЕсли;
	
	Если Не ПустаяСтрока(СтрокаОбработчика.Комментарий) Тогда
		Отступ = Символы.ПС + Символы.ПС;
	Иначе
		Отступ = "";
	КонецЕсли;
	
	Если ВыполняетсяИзменениеПриоритета И СтрокаСписка.Приоритет = "Неопределено" Тогда
		// Приоритет для данной строки не изменяется.
	ИначеЕсли СтрокаОбработчика.Приоритет = "ЖелательноБыстрее" Тогда
		СтрокаСписка.КартинкаПриоритет = БиблиотекаКартинок.ВосклицательныйЗнакКрасный;
		СтрокаСписка.Приоритет = СтрокаОбработчика.Приоритет;
	Иначе
		СтрокаСписка.КартинкаПриоритет = Новый Картинка;
		СтрокаСписка.Приоритет = "ВПлановомПорядке";
	КонецЕсли;
	
	Если СтрокаОбработчика.Статус <> Перечисления.СтатусыОбработчиковОбновления.Ошибка Тогда
		СтрокаСписка.ИнформацияОПроцедуреОбновления = СтрокаОбработчика.Комментарий
			+ Отступ
			+ СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ШаблонИнформацияОПроцедуреОбновления,
				СтрокаОбработчика.ИмяОбработчика,
				ПредставлениеСтатусаВыполнения);
	КонецЕсли;
	
	СтрокаСписка.ИнтервалВыполнения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		ШаблонИнтервалВыполнения,
		Строка(НачалоОбработкиДанных),
		Строка(ЗавершениеОбработкиДанных));
	
КонецПроцедуры

&НаСервере
Функция ПроцедураОбработкиДанных(ИмяОбработчика)
	ИмяОбработчикаМассив = СтрРазделить(ИмяОбработчика, ".");
	ЭлементовМассива = ИмяОбработчикаМассив.Количество();
	Возврат ИмяОбработчикаМассив[ЭлементовМассива-1];
КонецФункции

&НаСервере
Функция ДлительностьВыполненияПроцедурыОбновления(ДлительностьВыполнения, МаксимальнаяДлительность)
	
	Если ДлительностьВыполнения = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(МаксимальнаяДлительность)
		И ДлительностьВыполнения > МаксимальнаяДлительность Тогда
		ДлительностьВыполнения = МаксимальнаяДлительность;
	КонецЕсли;
	
	ШаблонСекунды = НСтр("ru = '%1 сек.'");
	ШаблонМинуты = НСтр("ru = '%1 мин. %2 сек.'");
	ШаблонЧасы = НСтр("ru = '%1 ч. %2 мин.'");
	
	ДлительностьВСекундах = ДлительностьВыполнения/1000;
	ДлительностьВСекундах = Окр(ДлительностьВСекундах);
	Если ДлительностьВСекундах < 1 Тогда
		Возврат НСтр("ru = 'менее секунды'")
	ИначеЕсли ДлительностьВСекундах < 60 Тогда
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСекунды, ДлительностьВСекундах);
	ИначеЕсли ДлительностьВСекундах < 3600 Тогда
		Минуты = ДлительностьВСекундах/60;
		Секунды = (Минуты - Цел(Минуты))*60;
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонМинуты, Цел(Минуты), Цел(Секунды));
	Иначе
		Часы = ДлительностьВСекундах/60/60;
		Минуты = (Часы - Цел(Часы))*60;
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЧасы, Цел(Часы), Цел(Минуты));
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ИзменяемыеОбработчики(Обработчик, ОбрабатываемыеДанныеТаблица, Очередь, ПриоритетЖелательноБыстрее, СписокОбъектов = Неопределено)
	
	ОбъектыОбработчиков = ПолучитьИзВременногоХранилища(ОбъектыОбработчикаАдрес);
	Если СписокОбъектов = Неопределено Тогда
		СписокОбъектов = ОбъектыОбработчиков[Обработчик];
		Если СписокОбъектов = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	ИзменяемыеОбработчики = Новый Массив;
	ИзменяемыеОбработчики.Добавить(Обработчик);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	втОбрабатываемыеОбъекты.Обработчик,
		|	втОбрабатываемыеОбъекты.ИмяОбъекта,
		|	втОбрабатываемыеОбъекты.Очередь
		|ПОМЕСТИТЬ Таблица
		|ИЗ
		|	&втОбрабатываемыеОбъекты КАК втОбрабатываемыеОбъекты
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Таблица.Обработчик,
		|	Таблица.ИмяОбъекта,
		|	Таблица.Очередь
		|ИЗ
		|	Таблица КАК Таблица
		|ГДЕ
		|	Таблица.ИмяОбъекта В(&СписокОбъектов)
		|	И Таблица.Очередь < &НомерОчереди";
	Если Не ПриоритетЖелательноБыстрее Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "И Таблица.Очередь < &НомерОчереди", "И Таблица.Очередь > &НомерОчереди");
	КонецЕсли;
	Запрос.УстановитьПараметр("СписокОбъектов", СписокОбъектов);
	Запрос.УстановитьПараметр("НомерОчереди", Очередь);
	Запрос.УстановитьПараметр("втОбрабатываемыеОбъекты", ОбрабатываемыеДанныеТаблица);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	ТекущийОбработчик = Неопределено;
	Для Каждого Строка Из Результат Цикл
		Если ТекущийОбработчик = Строка.Обработчик Тогда
			Продолжить;
		КонецЕсли;
		
		Если Строка.Очередь = 1 Тогда
			ИзменяемыеОбработчики.Добавить(Строка.Обработчик);
			ТекущийОбработчик = Строка.Обработчик;
			Продолжить;
		КонецЕсли;
		НовыйСписокОбъектов = Новый СписокЗначений;
		СписокОбъектовТекущегоОбработчика = ОбъектыОбработчиков[Строка.Обработчик];
		Для Каждого ОбъектТекущегоОбработчика Из СписокОбъектовТекущегоОбработчика Цикл
			Если СписокОбъектов.НайтиПоЗначению(ОбъектТекущегоОбработчика) = Неопределено Тогда
				НовыйСписокОбъектов.Добавить(ОбъектТекущегоОбработчика);
			КонецЕсли;
		КонецЦикла;
		
		Если НовыйСписокОбъектов.Количество() = 0 Тогда
			ИзменяемыеОбработчики.Добавить(Строка.Обработчик);
			ТекущийОбработчик = Строка.Обработчик;
			Продолжить;
		КонецЕсли;
		НовыйМассивИзменяемыхОбработчиков = ИзменяемыеОбработчики(Строка.Обработчик, // @skip-check query-in-loop - рекурсивная выборка зависимых обработчиков.
			ОбрабатываемыеДанныеТаблица,
			Строка.Очередь,
			ПриоритетЖелательноБыстрее,
			НовыйСписокОбъектов);
		
		Для Каждого ЭлементМассива Из НовыйМассивИзменяемыхОбработчиков Цикл
			Если ИзменяемыеОбработчики.Найти(ЭлементМассива) = Неопределено Тогда
				ИзменяемыеОбработчики.Добавить(ЭлементМассива);
			КонецЕсли;
		КонецЦикла;
		
		ТекущийОбработчик = Строка.Обработчик;
	КонецЦикла;
	
	Возврат ИзменяемыеОбработчики;
	
КонецФункции

&НаСервере
Процедура ИзменитьПриоритет(Приоритет, Обработчик, Очередь)
	
	ОбрабатываемыеДанныеТаблица = РеквизитФормыВЗначение("ОбрабатываемыеДанные");
	Если Очередь > 1 Тогда
		ИзменяемыеОбработчики = ИзменяемыеОбработчики(Обработчик,
			ОбрабатываемыеДанныеТаблица,
			Очередь,
			Приоритет = "ПриоритетЖелательноБыстрее");
		Если ИзменяемыеОбработчики = Неопределено Тогда
			ИзменяемыеОбработчики = Новый Массив;
			ИзменяемыеОбработчики.Добавить(Обработчик);
		КонецЕсли;
	Иначе
		ИзменяемыеОбработчики = Новый Массив;
		ИзменяемыеОбработчики.Добавить(Обработчик);
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		Блокировка.Добавить("Константа.СведенияОбОбновленииИБ");
		Блокировка.Заблокировать();
		
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		
		Если СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Свойство(Приоритет)
			И ТипЗнч(СведенияОбОбновлении.УправлениеОтложеннымОбновлением[Приоритет]) = Тип("Массив") Тогда
			Коллекция = СведенияОбОбновлении.УправлениеОтложеннымОбновлением[Приоритет];
			Для Каждого ИзменяемыйОбработчик Из ИзменяемыеОбработчики Цикл
				Если Коллекция.Найти(ИзменяемыйОбработчик) = Неопределено Тогда
					Коллекция.Добавить(ИзменяемыйОбработчик);
				КонецЕсли;
			КонецЦикла;
		Иначе
			СведенияОбОбновлении.УправлениеОтложеннымОбновлением.Вставить(Приоритет, ИзменяемыеОбработчики);
		КонецЕсли;
		
		ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Функция ДоступныеИсправленияНаСервере()
	Возврат ОбновлениеИнформационнойБазыСлужебный.ДоступныеДляУстановкиИсправления();
КонецФункции

&НаКлиенте
Процедура ПроверитьДоступныеИсправленияПродолжение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Значение = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	ДлительнаяОперация    = ЗапускУстановкиИсправлений();
	ПараметрыОжидания     = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ОбработатьРезультатРучнойУстановкиПатчей", ОбновлениеИнформационнойБазыКлиент, ДополнительныеПараметры);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция ЗапускУстановкиИсправлений()
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияФункции(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Установка доступных исправлений после ошибки обновления.'");
	Возврат ДлительныеОперации.ВыполнитьФункцию(ПараметрыВыполнения, "ПолучениеОбновленийПрограммы.ЗагрузитьИУстановитьИсправления");
	
КонецФункции

#КонецОбласти
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
	
	Дата                        = Параметры.Дата;
	ИмяПользователя             = Параметры.ИмяПользователя;
	ПредставлениеПриложения     = Параметры.ПредставлениеПриложения;
	Компьютер                   = Параметры.Компьютер;
	Событие                     = Параметры.Событие;
	ПредставлениеСобытия        = Параметры.ПредставлениеСобытия;
	Комментарий                 = Параметры.Комментарий;
	ПредставлениеМетаданных     = Параметры.ПредставлениеМетаданных;
	Данные                      = Параметры.Данные;
	ПредставлениеДанных         = Параметры.ПредставлениеДанных;
	Транзакция                  = Параметры.Транзакция;
	СтатусТранзакции            = Параметры.СтатусТранзакции;
	Сеанс                       = Параметры.Сеанс;
	РабочийСервер               = Параметры.РабочийСервер;
	ОсновнойIPПорт              = Параметры.ОсновнойIPПорт;
	ВспомогательныйIPПорт       = Параметры.ВспомогательныйIPПорт;
	
	Если ЗначениеЗаполнено(Параметры.Пользователь)
	   И СтроковыеФункцииКлиентСервер.ЭтоУникальныйИдентификатор(Параметры.Пользователь)
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		УстановитьПривилегированныйРежим(Истина);
		ИдентификаторПользователяИБ = Новый УникальныйИдентификатор(Параметры.Пользователь);
		Если ЗначениеЗаполнено(ИдентификаторПользователяИБ) Тогда
			Пользователь = Пользователи.НайтиПоИдентификатору(ИдентификаторПользователяИБ);
			Если Не ЗначениеЗаполнено(Пользователь) Тогда
				ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
					ИдентификаторПользователяИБ);
				Если ПользовательИБ <> Неопределено И ПользовательИБ.Имя = "" Тогда
					ИдентификаторПользователяИБ = ОбщегоНазначенияКлиентСервер.ПустойУникальныйИдентификатор();
					Пользователь = Пользователи.НайтиПоИдентификатору(ИдентификаторПользователяИБ);
				КонецЕсли;
			КонецЕсли;
			Если ЗначениеЗаполнено(Пользователь) Тогда
				Элементы.ИмяПользователя.КнопкаОткрытия = Истина;
			КонецЕсли;
		КонецЕсли;
		УстановитьПривилегированныйРежим(Ложь);
	КонецЕсли;
	
	ВидимостьРазделения = Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных();
	РазделениеДанныхСеанса = Параметры.РазделениеДанныхСеанса;
	
	Если ЖурналРегистрации.ТолькоСтандартныеРазделители() Тогда
		ОбластьДанных = Параметры.ОбластьДанных;
		Элементы.ОбластьДанных.Видимость = ВидимостьРазделения;
		Элементы.РазделениеДанныхСеанса.Видимость = Ложь;
	Иначе
		Элементы.ОбластьДанных.Видимость = Ложь;
		Элементы.РазделениеДанныхСеанса.Видимость = ВидимостьРазделения;
	КонецЕсли;
	
	Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 от %2'"), 
		Параметры.Уровень, Дата);
	
	// Для списка метаданных включается кнопка открытия.
	Если ТипЗнч(ПредставлениеМетаданных) = Тип("СписокЗначений") Тогда
		Элементы.ПредставлениеМетаданных.КнопкаОткрытия = Истина;
	КонецЕсли;
	
	// Обработка данных специальных событий.
	Элементы.ЗаголовокТаблицы.Видимость = Ложь;
	Элементы.ДеревоДанных.Видимость = Ложь;
	Элементы.ДанныеПользователяИБ.Видимость = Ложь;
	Элементы.ПредставленияДанных.ОтображениеСтраниц = ОтображениеСтраницФормы.Нет;
	
	ДанныеСобытия = ЖурналРегистрации.ДанныеСобытия(Параметры.ДанныеСтрокой); // Структура
	
	Если ТипЗнч(ДанныеСобытия) = Тип("Строка") Тогда
		ДанныеСобытия = ЖурналРегистрации.ДанныеИзСтрокиXML(ДанныеСобытия);
	КонецЕсли;
	
	Если Событие = "_$Access$_.Access" Тогда
		Элементы.Данные.Видимость = Ложь;
		Элементы.ПредставлениеДанных.Видимость = Ложь;
		Если ДанныеСобытия <> Неопределено И ДанныеСобытия.Свойство("Данные") И ДанныеСобытия.Данные <> Неопределено Тогда
			СоздатьТаблицуФормы("ТаблицаДанных", "ТаблицаДанных", ДанныеСобытия.Данные);
		ИначеЕсли ДанныеСобытия <> Неопределено Тогда
			СоздатьТаблицуФормы("ТаблицаДанных", "ТаблицаДанных", ДанныеСобытия);
		КонецЕсли;
		
	ИначеЕсли Событие = "_$Access$_.AccessDenied" Тогда
		Элементы.Данные.Видимость = Ложь;
		
		Если ДанныеСобытия <> Неопределено Тогда
			Если ДанныеСобытия.Свойство("Право") Тогда
				Элементы.ПредставлениеДанных.Заголовок = НСтр("ru = 'Отказ права'");
				ПредставлениеДанных = ДанныеСобытия.Право;
			Иначе
				Элементы.ПредставлениеДанных.Заголовок = НСтр("ru = 'Отказ действия'");
				ПредставлениеДанных = ДанныеСобытия.Действие;
				Если ДанныеСобытия.Свойство("Данные") И ДанныеСобытия.Данные <> Неопределено Тогда
					СоздатьТаблицуФормы("ТаблицаДанных", "ТаблицаДанных", ДанныеСобытия.Данные);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
	ИначеЕсли Событие = "_$User$_.Delete"
		  Или Событие = "_$User$_.New"
		  Или Событие = "_$User$_.Update" Тогда
		
		Элементы.СтандартныеДанные.Видимость = Ложь;
		Элементы.ДанныеПользователяИБ.Видимость = Истина;
		Элементы.ПредставленияДанных.ТекущаяСтраница = Элементы.ДанныеПользователяИБ;
		
		Если ДанныеСобытия <> Неопределено Тогда
			Если ДанныеСобытия.Свойство("Роли") Тогда
				Если ТипЗнч(ДанныеСобытия.Роли) = Тип("Массив") Тогда
					РолиПользователяИБ = ЖурналРегистрации.ТаблицаРолей(ДанныеСобытия.Роли);
					СоздатьТаблицуФормы("ТаблицаРолейПользователяИБ", "ТаблицаРолей", РолиПользователяИБ);
				КонецЕсли;
				ДанныеСобытия.Удалить("Роли");
			КонецЕсли;
			СоздатьТаблицуФормы("ТаблицаСвойствПользователяИБ", "ТаблицаДанных", ДанныеСобытия);
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(ДанныеСобытия) = Тип("Структура")
	      Или ТипЗнч(ДанныеСобытия) = Тип("ФиксированнаяСтруктура")
	      Или ТипЗнч(ДанныеСобытия) = Тип("ТаблицаЗначений") Тогда
		
		Элементы.Данные.Видимость = Ложь;
		Элементы.ПредставлениеДанных.Видимость = Ложь;
		СоздатьТаблицуФормы("ТаблицаДанных", "ТаблицаДанных", ДанныеСобытия);
	КонецЕсли;
	
	СтандартныеПодсистемыСервер.СброситьРазмерыИПоложениеОкна(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИмяПользователяОткрытие(Элемент, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(Пользователь) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(, Пользователь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КомментарийОткрытие(Элемент, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(Комментарий) Тогда
		Текст = Новый ТекстовыйДокумент;
		Текст.УстановитьТекст(Комментарий);
		Текст.Показать(Заголовок + " (" + НСтр("ru = 'Комментарий'") + ")");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеМетаданныхОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПоказатьЗначение(, ПредставлениеМетаданных);
	
КонецПроцедуры

&НаКлиенте
Процедура РазделениеДанныхСеансаОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПоказатьЗначение(, РазделениеДанныхСеанса);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыТаблицаДанныхОтказаДействияДоступа

&НаКлиенте
Процедура ТаблицаДанныхВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Значение = Элемент.ТекущиеДанные[Сред(Поле.Имя, СтрДлина(Элемент.Имя)+1)];
	
	Если СтрНачинаетсяС(Значение, "{""#"",")
	   И СтрЗаканчиваетсяНа(Значение, "}")
	   И СтрРазделить(Значение, ",").Количество() = 3 Тогда
		
		Ссылка = ИсходнаяСсылка(Значение);
		Если ЗначениеЗаполнено(Ссылка) Тогда
			Значение = Ссылка;
			
		ИначеЕсли Ссылка <> Неопределено Тогда
			Значение = "<" + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Пустая ссылка %1'"), ТипЗнч(Ссылка)) + ">";
		Иначе
			Значение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось получить ссылку из строки (возможно тип ссылки не существует):
				           |%1'"), Значение);
		КонецЕсли;
	ИначеЕсли СтрНачинаетсяС(Значение, "e1cib/") Тогда
		ФайловаяСистемаКлиент.ОткрытьНавигационнуюСсылку(Значение);
		Возврат;
	КонецЕсли;
	
	ПоказатьЗначение(, Значение);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура РазвернутьТаблицу(Команда)
	УстановитьВидимостьГруппКромеТаблицы(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура СвернутьТаблицу(Команда)
	УстановитьВидимостьГруппКромеТаблицы(Истина);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СоздатьТаблицуФормы(Знач ИмяПоляТаблицыФормы, Знач ИмяРеквизитаДанныеФормыКоллекция, Знач ТаблицаЗначений)
	
	Если Не ЗначениеЗаполнено(Комментарий) Тогда
		Элементы.Комментарий.РастягиватьПоВертикали = Ложь;
		Элементы.Комментарий.Высота = 1;
	КонецЕсли;
	
	Если ТипЗнч(ТаблицаЗначений) = Тип("Структура")
	 Или ТипЗнч(ТаблицаЗначений) = Тип("ФиксированнаяСтруктура") Тогда
		
		ДеревоЗначений = ЖурналРегистрации.ДеревоИзДанныхСтруктуры(ТаблицаЗначений);
		Отбор = Новый Структура("ЕстьЗначение", Ложь);
		ЕстьВложения = ДеревоЗначений.Строки.НайтиСтроки(Отбор).Количество() <> 0;
		Если ЕстьВложения Тогда
			Элементы.ДеревоДанных.Видимость = Истина;
			Элементы.ЗаголовокТаблицы.Видимость = Истина;
			ЗначениеВРеквизитФормы(ДеревоЗначений, "ДеревоДанных");
			Возврат;
		КонецЕсли;
		ДеревоЗначений.Колонки.Удалить("ЕстьЗначение");
		ТаблицаЗначений = Новый ТаблицаЗначений;
		Для Каждого Колонка Из ДеревоЗначений.Колонки Цикл
			ТаблицаЗначений.Колонки.Добавить(Колонка.Имя, Колонка.ТипЗначения, Колонка.Заголовок);
		КонецЦикла;
		Для Каждого Строка Из ДеревоЗначений.Строки Цикл
			ЗаполнитьЗначенияСвойств(ТаблицаЗначений.Добавить(), Строка);
		КонецЦикла;
		Элементы[ИмяПоляТаблицыФормы].Шапка = Ложь;
		
	ИначеЕсли ТипЗнч(ТаблицаЗначений) <> Тип("ТаблицаЗначений") Тогда
		ТаблицаЗначений = Новый ТаблицаЗначений;
		ТаблицаЗначений.Колонки.Добавить("Неопределено", , " ");
	КонецЕсли;
	
	Если ИмяПоляТаблицыФормы = "ТаблицаДанных" Тогда
		Элементы.ЗаголовокТаблицы.Видимость = Истина;
		Элементы.ДеревоДанныхКоманды.Видимость = Ложь;
		Элементы.ТаблицаДанныхКоманды.Видимость = Истина;
	КонецЕсли;
	
	// Добавление реквизитов в таблицу формы.
	ДобавляемыеРеквизиты = Новый Массив;
	Для каждого Колонка Из ТаблицаЗначений.Колонки Цикл
		ДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы(Колонка.Имя,
			Колонка.ТипЗначения, ИмяРеквизитаДанныеФормыКоллекция, Колонка.Заголовок));
	КонецЦикла;
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	// Добавление элементов форму
	Для Каждого Колонка Из ТаблицаЗначений.Колонки Цикл
		ЭлементРеквизита = Элементы.Добавить(ИмяПоляТаблицыФормы + Колонка.Имя, Тип("ПолеФормы"), Элементы[ИмяПоляТаблицыФормы]);
		ЭлементРеквизита.ПутьКДанным = ИмяРеквизитаДанныеФормыКоллекция + "." + Колонка.Имя;
		ЭлементРеквизита.АвтоВысотаЯчейки = Истина;
	КонецЦикла;
	
	Для Каждого Строка Из ТаблицаЗначений Цикл
		НоваяСтрока = ЭтотОбъект[ИмяРеквизитаДанныеФормыКоллекция].Добавить();
		Попытка
			ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
		Исключение
			Для Каждого Колонка Из ТаблицаЗначений.Колонки Цикл
				Попытка
					НоваяСтрока[Колонка.Имя] = Строка[Колонка.Имя];
				Исключение
					НоваяСтрока[Колонка.Имя] = Строка(Строка[Колонка.Имя]); // Тип НеизвестныйОбъект
				КонецПопытки;
			КонецЦикла;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ДеревоДанныхЗначение.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДеревоДанных.ЕстьЗначение");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Ложь;
	
	Элемент.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ИсходнаяСсылка(СериализованнаяСсылка)
	
	Попытка
		Ссылка = ЗначениеИзСтрокиВнутр(СериализованнаяСсылка);
	Исключение
		Ссылка = Неопределено;
	КонецПопытки;
	
	Если Не ОбщегоНазначения.ЭтоСсылка(ТипЗнч(Ссылка)) Тогда
		Ссылка = Неопределено;
	КонецЕсли;
	
	Возврат Ссылка;
	
КонецФункции

&НаКлиенте
Процедура УстановитьВидимостьГруппКромеТаблицы(Видимость)
	
	Элементы.ГруппаКнопок.Видимость = Видимость;
	Элементы.ГруппаОсновное.Видимость = Видимость;
	Элементы.ГруппаСобытие.Видимость = Видимость;
	Элементы.ГруппаДанные.ОтображатьЗаголовок = Видимость;
	Элементы.СтандартныеДанныеСвойства.Видимость = Видимость;
	Элементы.ГруппаТранзакцияСоединение.Видимость = Видимость;
	
КонецПроцедуры

#КонецОбласти

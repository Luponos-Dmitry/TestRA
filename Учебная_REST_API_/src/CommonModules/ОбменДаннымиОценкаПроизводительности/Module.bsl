///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

Процедура Инициализировать(КомпонентыОбмена, Анализ = Ложь) Экспорт

	КомпонентыОбмена.ВыполнятьЗамеры = КомпонентыОбмена.ЭтоОбменЧерезПланОбмена 
		И Константы.ИспользоватьОценкуПроизводительностиСинхронизацииДанных.Получить();
		
	Если НЕ КомпонентыОбмена.ВыполнятьЗамеры Тогда
		Возврат;
	КонецЕсли;
	
	СеансОбмена = Справочники.СеансыОбменовДанными.СоздатьЭлемент();
	
	КодОсновногоЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
	
	ШаблонНаименования = НСтр("ru = '%1 в %2 для ""%3"" (%4)'", КодОсновногоЯзыка); // Отправка в 18.07.2022 15:09 для "Бухгалтерия предприятия 3.0"
	Наименование = СтрШаблон(ШаблонНаименования,
		КомпонентыОбмена.НаправлениеОбмена,
		ТекущаяДатаСеанса(),
		КомпонентыОбмена.УзелКорреспондента,
		КомпонентыОбмена.УзелКорреспондента.Код);
				
	Если Анализ Тогда
		Наименование = Наименование + " " + НСтр("ru = '(Анализ)'", КодОсновногоЯзыка);
	КонецЕсли;
	
	СеансОбмена.Наименование = Наименование;
		
	СеансОбмена.УзелИнформационнойБазы = КомпонентыОбмена.УзелКорреспондента;
	СеансОбмена.Начало = ТекущаяДатаСеанса();
	
	Если КомпонентыОбмена.НаправлениеОбмена = "Отправка" Тогда
		СеансОбмена.Отправка = Истина;
	ИначеЕсли КомпонентыОбмена.НаправлениеОбмена = "Получение" Тогда
		СеансОбмена.Получение = Истина;
	КонецЕсли;
	
	СеансОбмена.Записать();
		
	КомпонентыОбмена.СеансОбмена = СеансОбмена;
	
	Каталог = ОбменДаннымиПовтИсп.КаталогВременногоХранилищаФайлов();
	ИмяВременногоФайлаЗамеров = Каталог + "log.txt"; //АПК:441 временный файл будет удален при подведении итогов
	КомпонентыОбмена.ИмяВременногоФайлаЗамеров = ИмяВременногоФайлаЗамеров;
	КомпонентыОбмена.ЗаписьЗамеров = Новый ЗаписьТекста(ИмяВременногоФайлаЗамеров, КодировкаТекста.UTF8);
	
	ЗаголовокЛога = НСтр("ru = 'Начало замера; Время выполнения; ТипСобытия; Событие; Комментарий'");
	КомпонентыОбмена.ЗаписьЗамеров.ЗаписатьСтроку(ЗаголовокЛога, КодОсновногоЯзыка);
	
	НачатьТранзакцию();
	Попытка
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.СеансыОбменовДанными");
		ЭлементБлокировки.УстановитьЗначение("УзелИнформационнойБазы", КомпонентыОбмена.УзелКорреспондента);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Блокировка.Заблокировать();
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	СеансыОбменовДанными.Ссылка,
			|	СеансыОбменовДанными.Начало КАК Начало
			|ИЗ
			|	Справочник.СеансыОбменовДанными КАК СеансыОбменовДанными
			|ГДЕ
			|	СеансыОбменовДанными.УзелИнформационнойБазы = &Узел
			|	И СеансыОбменовДанными.Отправка = &Отправка
			|	И СеансыОбменовДанными.Получение = &Получение
			|
			|УПОРЯДОЧИТЬ ПО
			|	Начало";
			
		Запрос.УстановитьПараметр("Узел", КомпонентыОбмена.УзелКорреспондента);
		Запрос.УстановитьПараметр("Отправка", СеансОбмена.Отправка);
		Запрос.УстановитьПараметр("Получение", СеансОбмена.Получение);
		
		ТаблицаСеансов = Запрос.Выполнить().Выгрузить();
		
		Для Сч = 1 По ТаблицаСеансов.Количество() - 5 Цикл
			СеансОбмена = ТаблицаСеансов[0].Ссылка.ПолучитьОбъект();
			СеансОбмена.Удалить();
			ТаблицаСеансов.Удалить(0);
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	
	Исключение
		
		ОтменитьТранзакцию();
	
		СтрокаСообщения = НСтр("ru = 'Ошибка при попытке удаления сеанса обмена: %1. Описание ошибки: %2'",
			ОбщегоНазначения.КодОсновногоЯзыка());
			
		СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщения,
			СеансОбмена, ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			
		ЗаписьЖурналаРегистрации(ОбменДаннымиСервер.СобытиеЖурналаРегистрацииОбменДанными(),
			УровеньЖурналаРегистрации.Ошибка,,, СтрокаСообщения);
			
	КонецПопытки
	
КонецПроцедуры

Процедура Завершить(КомпонентыОбмена) Экспорт
	
	Если НЕ КомпонентыОбмена.ВыполнятьЗамеры Тогда
		Возврат;
	КонецЕсли;
		
	СеансОбмена = КомпонентыОбмена.СеансОбмена;
	ИмяВременногоФайлаЗамеров = КомпонентыОбмена.ИмяВременногоФайлаЗамеров;
	
	КомпонентыОбмена.ВыполнятьЗамеры = Ложь;
	КомпонентыОбмена.ЗаписьЗамеров.Закрыть();
	
	ВремяНачала = СеансОбмена.Начало;
	ВремяОкончания = ТекущаяДатаСеанса();
	
	Каталог = ОбменДаннымиПовтИсп.КаталогВременногоХранилищаФайлов();
	ИмяАрхива = Формат(СеансОбмена.Начало, "ДФ=yyyy-MM-dd-HH-mm-ss") + "_" 
		+ Строка(СеансОбмена.Ссылка.УникальныйИдентификатор()) + ".zip";
	
	ИмяВременногоФайлаИтогов = Каталог + "total.txt";
	ИмяВременногоФайлаАрхива = Каталог +  ИмяАрхива;
	
	ЗаписьИтогов = Новый ЗаписьТекста(ИмяВременногоФайлаИтогов);
	
	КодОсновногоЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
	
	// Шапка
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = '--- Сеанс обмена ---'", КодОсновногоЯзыка));
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = 'Направление обмена:'", КодОсновногоЯзыка) + КомпонентыОбмена.НаправлениеОбмена);
	
	Шаблон = НСтр("ru = 'Узел: %1 (%2)'", КодОсновногоЯзыка); 
	ЗаписьИтогов.ЗаписатьСтроку(СтрШаблон(Шаблон, 
		КомпонентыОбмена.УзелКорреспондента,
		КомпонентыОбмена.УзелКорреспондента.Код));
	
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = 'Начало:'", КодОсновногоЯзыка) + ВремяНачала);
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = 'Окончание:'", КодОсновногоЯзыка) + ВремяОкончания);
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = 'Время выполнения (сек):'", КодОсновногоЯзыка) + (ВремяОкончания - ВремяНачала));
	ЗаписьИтогов.ЗаписатьСтроку("");
	
	// Итоги по типу событий
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = '--- Итоговые значения по типам ---'", КодОсновногоЯзыка));
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = 'Тип события; Время выполнения'", КодОсновногоЯзыка));
	
	ТаблицаЗамеровПоТипамСобытий = КомпонентыОбмена.ТаблицаЗамеровПоСобытиям.Скопировать(, "ТипСобытия, ВремяВыполнения");
	ТаблицаЗамеровПоТипамСобытий.Свернуть("ТипСобытия", "ВремяВыполнения");
	
	Шаблон = "%1; %2";
	Для Каждого СтрокаТаблицы Из ТаблицаЗамеровПоТипамСобытий Цикл
	
		Строка = СтрШаблон(Шаблон, 
			СтрокаТаблицы.ТипСобытия,
			СтрокаТаблицы.ВремяВыполнения);
		
		ЗаписьИтогов.ЗаписатьСтроку(Строка);
			
	КонецЦикла;
	
	ЗаписьИтогов.ЗаписатьСтроку("");
	
	// Итоги по событиям
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = '--- Итоговые значения по событиям ---'", КодОсновногоЯзыка));
	ЗаписьИтогов.ЗаписатьСтроку(НСтр("ru = 'Процент; Ср. время; Время; Кол-во событий; Тип события; Событие'", КодОсновногоЯзыка));
	
	ТаблицаЗамеров = КомпонентыОбмена.ТаблицаЗамеровПоСобытиям;
	ТаблицаЗамеров.Сортировать("ВремяВыполнения Убыв");
	
	ВремяВыполненияИтог = ТаблицаЗамеров.Итог("ВремяВыполнения"); 
	
	Шаблон = "%1; %2; %3; %4; %5; %6";
		
	Для Каждого СтрокаТаблицы Из ТаблицаЗамеров Цикл
		
		Если ВремяВыполненияИтог > 0 Тогда
			Процент = Окр(СтрокаТаблицы.ВремяВыполнения / ВремяВыполненияИтог * 100, 3);
		Иначе
			Процент = 0;
		КонецЕсли;
		Процент = СтроковыеФункцииКлиентСервер.ДополнитьСтроку(Процент, 7, " ", "Слева");
				
		СреднееВремяВыполнения = Окр(СтрокаТаблицы.ВремяВыполнения / СтрокаТаблицы.Количество, 3);
		СреднееВремяВыполнения = СтроковыеФункцииКлиентСервер.ДополнитьСтроку(СреднееВремяВыполнения, 7, " ", "Слева");
		
		ВремяВыполнения = Окр(СтрокаТаблицы.ВремяВыполнения, 3);
		ВремяВыполнения = Формат(ВремяВыполнения,"ЧГ=;");
		ВремяВыполнения = СтроковыеФункцииКлиентСервер.ДополнитьСтроку(ВремяВыполнения, 7, " ", "Слева");
		
		Количество = Формат(СтрокаТаблицы.Количество,"ЧГ=;");
		Количество = СтроковыеФункцииКлиентСервер.ДополнитьСтроку(СтрокаТаблицы.Количество, 7, " ", "Слева");
		ТипСобытия = СтроковыеФункцииКлиентСервер.ДополнитьСтроку(СтрокаТаблицы.ТипСобытия, 11, " ", "Справа");
		
		Строка = СтрШаблон(Шаблон,
			Процент,
			СреднееВремяВыполнения,
			ВремяВыполнения,
			Количество,
			ТипСобытия,
			СтрокаТаблицы.Событие); 
			
		ЗаписьИтогов.ЗаписатьСтроку(Строка);
		
	КонецЦикла;
	
	ЗаписьИтогов.Закрыть();
	
	//	
	СеансОбмена.Окончание = ВремяОкончания;
	СеансОбмена.ВремяВыполнения = ВремяОкончания - ВремяНачала;
	
	Архив = Новый ЗаписьZipФайла(ИмяВременногоФайлаАрхива);
	Архив.Добавить(ИмяВременногоФайлаЗамеров);
	Архив.Добавить(ИмяВременногоФайлаИтогов);
	Архив.Записать();
		
	СеансОбмена.ЗамерыПроизводительности = Новый ХранилищеЗначения(Новый ДвоичныеДанные(ИмяВременногоФайлаАрхива));
	СеансОбмена.Записать();
	
	// Удаление временных файлов
	УдалитьФайлы(ИмяВременногоФайлаИтогов);
	УдалитьФайлы(ИмяВременногоФайлаАрхива);
	УдалитьФайлы(ИмяВременногоФайлаЗамеров);
	 
КонецПроцедуры

Функция НачатьЗамер() Экспорт
		
	Возврат ТекущаяУниверсальнаяДатаВМиллисекундах();
	
КонецФункции

Процедура ЗавершитьЗамер(ВремяНачала, Событие, Объект, КомпонентыОбмена, ТипСобытия) Экспорт

	Если Событие = "" Или НЕ КомпонентыОбмена.ВыполнятьЗамеры Тогда
		Возврат;
	КонецЕсли;
	
	Начало = Дата(1,1,1) + ВремяНачала / 1000;
	
	ВремяОкончания = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ВремяВыполнения = Окр((ВремяОкончания - ВремяНачала) / 1000, 3);
	
	ПредставлениеОбъекта = ПредставлениеОбъекта(Объект);
	
	// Лог
	ШаблонСтроки = "%1; %2; %3; %4; %5";
		
	Строка = СтрШаблон(ШаблонСтроки,
		Начало,
		Формат(ВремяВыполнения,"ЧГ=;"),
		ТипСобытия,
		Событие,
		ПредставлениеОбъекта);
		
	ЗаписьЗамеров = КомпонентыОбмена.ЗаписьЗамеров;
	ЗаписьЗамеров.ЗаписатьСтроку(Строка);
	
	// Итоговые данные по событиям
	ТаблицаЗамеров = КомпонентыОбмена.ТаблицаЗамеровПоСобытиям;
	Замер = ТаблицаЗамеров.Найти(Событие, "Событие");
	
	Если Замер = Неопределено Тогда
		НовыйЗамер = ТаблицаЗамеров.Добавить();
		НовыйЗамер.Событие = Событие;
		НовыйЗамер.ТипСобытия = ТипСобытия;
		НовыйЗамер.Количество = 1;
		НовыйЗамер.ВремяВыполнения = ВремяВыполнения;
	Иначе 
		Замер.Количество = Замер.Количество + 1;
		Замер.ВремяВыполнения = Замер.ВремяВыполнения + ВремяВыполнения;
	КонецЕсли;
	
КонецПроцедуры

Функция ТаблицаЗамеровПоСобытиям() Экспорт

	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("Событие");
	Таблица.Колонки.Добавить("ТипСобытия");
	Таблица.Колонки.Добавить("Количество");
	Таблица.Колонки.Добавить("ВремяВыполнения");

	Таблица.Индексы.Добавить("Событие");
	
	Возврат Таблица;
	
КонецФункции

Функция ТипСобытияПравило() Экспорт

	Возврат НСтр("ru = 'Правила обменов'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

Функция ТипСобытияБиблиотека() Экспорт

	Возврат НСтр("ru = 'Подсистема обменов'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

Функция ТипСобытияПрикладное() Экспорт

	Возврат НСтр("ru = 'Остальная конфигурация'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции	

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПредставлениеОбъекта(Объект)

	Если ТипЗнч(Объект) = Тип("Структура") Тогда
		
		МассивКлючейИЗначений = Новый Массив;
		Шаблон = "%1 = ""%2""";
		
		Если Объект.Свойство("КлючевыеСвойства") Тогда
			
			Для Каждого КлючИЗначение Из Объект.КлючевыеСвойства Цикл
				
				Если Не ЗначениеЗаполнено(КлючИЗначение.Значение) 
					Или ТипЗнч(КлючИЗначение.Значение) = Тип("Структура") Тогда
					Продолжить;
				КонецЕсли;
				
				Строка = СтрШаблон(Шаблон, КлючИЗначение.Ключ, КлючИЗначение.Значение); 
				МассивКлючейИЗначений.Добавить(Строка);
				
			КонецЦикла;
			
		КонецЕсли;
		
		Возврат СтрСоединить(МассивКлючейИЗначений, ", ");
		
	Иначе
		
		Возврат Строка(Объект);
		
	КонецЕсли;

КонецФункции

#КонецОбласти
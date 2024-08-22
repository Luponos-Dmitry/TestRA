///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Процедура ЗаписатьДвоичныеДанные(Знач Файл, Знач ДвоичныеДанные) Экспорт
	
	Хеширование = Новый ХешированиеДанных(ХешФункция.SHA256);

	ЭтоПустыеДвоичныеДанные = (ДвоичныеДанные = Неопределено);
	Если ЭтоПустыеДвоичныеДанные Тогда
		ПустыеДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("");
		Хеширование.Добавить(ПустыеДвоичныеДанные);
		Размер = ПустыеДвоичныеДанные.Размер();
	Иначе
		Хеширование.Добавить(ДвоичныеДанные);
		Размер = ДвоичныеДанные.Размер();
	КонецЕсли;
	Хеш = ПолучитьBase64СтрокуИзДвоичныхДанных(Хеширование.ХешСумма);
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.ХранилищеДвоичныхДанных");
		ЭлементБлокировки.УстановитьЗначение("Хеш", Хеш);
		Блокировка.Заблокировать();
		
		УдалитьДвоичныеДанные(Файл);
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Хеш", Хеш);
		Запрос.УстановитьПараметр("Размер", Размер);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ХранилищеДвоичныхДанных.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ХранилищеДвоичныхДанных КАК ХранилищеДвоичныхДанных
		|ГДЕ
		|	ХранилищеДвоичныхДанных.Хеш = &Хеш
		|	И ХранилищеДвоичныхДанных.Размер = &Размер";
		Выборка = Запрос.Выполнить().Выбрать();
		ХранилищеДвоичныхДанныхСсылка = Неопределено;
		Если Выборка.Следующий() Тогда
			ХранилищеДвоичныхДанныхСсылка = Выборка.Ссылка;
		Иначе
			ХранилищеДвоичныхДанныхОбъект = Справочники.ХранилищеДвоичныхДанных.СоздатьЭлемент();
			ХранилищеДвоичныхДанныхОбъект.Размер = Размер;
			ХранилищеДвоичныхДанныхОбъект.Хеш = Хеш;
			ХранилищеДвоичныхДанныхОбъект.ДвоичныеДанные = ?(ЭтоПустыеДвоичныеДанные,
				Неопределено, Новый ХранилищеЗначения(ДвоичныеДанные, Новый СжатиеДанных(9)));
			ХранилищеДвоичныхДанныхОбъект.Записать();
			ХранилищеДвоичныхДанныхСсылка = ХранилищеДвоичныхДанныхОбъект.Ссылка;
		КонецЕсли;
		
		Запись = СоздатьМенеджерЗаписи();
		Запись.Файл = Файл;
		Запись.ХранилищеДвоичныхДанных = ХранилищеДвоичныхДанныхСсылка;
		Запись.Записать(Ложь);
		
		ЗафиксироватьТранзакцию();	
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Процедура УдалитьДвоичныеДанные(Файл) Экспорт
	
	НачатьТранзакцию();
	Попытка
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Файл", Файл);
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ХранилищеФайлов.ХранилищеДвоичныхДанных КАК ХранилищеДвоичныхДанных,
		|	ХранилищеФайлов.ХранилищеДвоичныхДанных.Хеш КАК Хеш
		|ИЗ
		|	РегистрСведений.ХранилищеФайлов КАК ХранилищеФайлов
		|ГДЕ
		|	ХранилищеФайлов.Файл = &Файл";
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить("Справочник.ХранилищеДвоичныхДанных");
			ЭлементБлокировки.УстановитьЗначение("Хеш", Выборка.Хеш);
			Блокировка.Заблокировать();
			
			Запись = СоздатьМенеджерЗаписи();
			Запись.Файл = Файл;
			Запись.Удалить();
			
			Запрос = Новый Запрос;
			Запрос.УстановитьПараметр("ХранилищеДвоичныхДанных", Выборка.ХранилищеДвоичныхДанных);
			Запрос.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	ИСТИНА КАК Проверка
			|ИЗ
			|	РегистрСведений.ХранилищеФайлов КАК ХранилищеФайлов
			|ГДЕ
			|	ХранилищеФайлов.ХранилищеДвоичныхДанных = &ХранилищеДвоичныхДанных";
			Если Запрос.Выполнить().Пустой() Тогда
				СпрОбъект = Выборка.ХранилищеДвоичныхДанных.ПолучитьОбъект();
				СпрОбъект.ОбменДанными.Загрузка = Истина;
				СпрОбъект.Удалить();
			КонецЕсли;
		КонецЕсли;
		
		Если Не РаботаСФайламиСлужебныйПовтИсп.ДедупликацияВыполнена() Тогда
			Запись = РегистрыСведений.УдалитьДвоичныеДанныеФайлов.СоздатьМенеджерЗаписи();
			Запись.Файл = Файл;
			Запись.Удалить();
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();	
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Функция НавигационнаяСсылкаФайла(Файл) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Файл", Файл);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ХранилищеФайлов.ХранилищеДвоичныхДанных КАК ХранилищеДвоичныхДанных
	|ИЗ
	|	РегистрСведений.ХранилищеФайлов КАК ХранилищеФайлов
	|ГДЕ
	|	ХранилищеФайлов.Файл = &Файл";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат ПолучитьНавигационнуюСсылку(Выборка.ХранилищеДвоичныхДанных, "ДвоичныеДанные");
	КонецЕсли;
	
	КлючЗаписи = РегистрыСведений.УдалитьДвоичныеДанныеФайлов.СоздатьКлючЗаписи(Новый Структура("Файл", Файл));
	
	Возврат ПолучитьНавигационнуюСсылку(КлючЗаписи, "ДвоичныеДанныеФайла");
		
КонецФункции

Процедура ПеренестиДанные(СообщатьПрогресс = Ложь, АдресРезультата = Неопределено) Экспорт
	
	ШаблонПрогресса = НСтр("ru = 'Обработано %1 (%2 Мб) файлов из %3 (%4 Мб)'");
	ВсегоЗаписей = 0;
	ВсегоРазмерМб = 0;
	Если СообщатьПрогресс Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(*) КАК ВсегоЗаписей
		|ИЗ
		|	РегистрСведений.УдалитьДвоичныеДанныеФайлов КАК УдалитьДвоичныеДанныеФайлов";
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ВсегоЗаписей = Выборка.ВсегоЗаписей;
		КонецЕсли;
		
		ВключитьОбъекты = Новый Массив();
		ВключитьОбъекты.Добавить(Метаданные.РегистрыСведений.УдалитьДвоичныеДанныеФайлов);
		ВсегоРазмерМб = Окр(ПолучитьРазмерДанныхБазыДанных(, ВключитьОбъекты) / 1024 / 1024, 0);
		Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонПрогресса, 
			0, 0, ВсегоЗаписей, ВсегоРазмерМб);
		ДлительныеОперации.СообщитьПрогресс(0, Текст);
	КонецЕсли;
	
	Выборка = РегистрыСведений.УдалитьДвоичныеДанныеФайлов.Выбрать();
	ЗаписейОбработано = 0;
	РазмерОбработано = 0;
	Ошибки = Новый Массив;
	Пока Выборка.Следующий() Цикл
		Файл = Выборка.Файл;
		НаименованиеФайла = Строка(Файл);
		НачатьТранзакцию();
		Попытка
			
			Блокировка = Новый БлокировкаДанных();
			Блокировка.Добавить("РегистрСведений.УдалитьДвоичныеДанныеФайлов").УстановитьЗначение("Файл", Файл);
			Блокировка.Добавить("РегистрСведений.ХранилищеФайлов").УстановитьЗначение("Файл", Файл);
			Блокировка.Заблокировать();
			
			ДвоичныеДанные = Выборка.ДвоичныеДанныеФайла.Получить();
			Если ТипЗнч(ДвоичныеДанные) = Тип("Картинка") Тогда
				ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
				ДвоичныеДанные.Записать(ИмяВременногоФайла);
				ДвоичныеДанные = Новый ДвоичныеДанные(ИмяВременногоФайла);
				
				ФайловаяСистема.УдалитьВременныйФайл(ИмяВременногоФайла);
			ИначеЕсли ТипЗнч(ДвоичныеДанные) <> Тип("ДвоичныеДанные") Тогда
				ТекстОшибки = НСтр("ru = 'В регистре сведений ""%1"" для файла ""%2"" хранятся данные типа ""%3"", а ожидалось ""%4"".'");
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки,
					Метаданные.РегистрыСведений.УдалитьДвоичныеДанныеФайлов.Имя,
					НаименованиеФайла,
					ТипЗнч(ДвоичныеДанные),
					Тип("ДвоичныеДанные"));
				ОписаниеОшибки = Новый Структура;
				ОписаниеОшибки.Вставить("ИмяФайла", ОбщегоНазначения.ПредметСтрокой(Файл));
				ОписаниеОшибки.Вставить("Ошибка", ТекстОшибки);
				ОписаниеОшибки.Вставить("ПодробноеПредставлениеОшибки", ТекстОшибки);
				ОписаниеОшибки.Вставить("Версия", Файл);
				Ошибки.Добавить(ОписаниеОшибки);
				
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Файлы.Ошибка дедупликации файла.'", ОбщегоНазначения.КодОсновногоЯзыка()),
					УровеньЖурналаРегистрации.Ошибка, , Файл, ТекстОшибки);
				ОтменитьТранзакцию();
				Продолжить;
			КонецЕсли;
			
			// @skip-check query-in-loop - порционная обработка больших объемов данных. 
			Если Не ЗаписьСуществует(Файл) Тогда
				ЗаписатьДвоичныеДанные(Файл, ДвоичныеДанные);
			КонецЕсли;
			
			Запись = РегистрыСведений.УдалитьДвоичныеДанныеФайлов.СоздатьМенеджерЗаписи();
			Запись.Файл = Файл;
			Запись.Удалить();
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
		
		Если СообщатьПрогресс Тогда
			ЗаписейОбработано = ЗаписейОбработано + 1;
			РазмерОбработано = РазмерОбработано + ДвоичныеДанные.Размер();
			Если ЗаписейОбработано % 100 = 0 Тогда
				Процент = Окр(ЗаписейОбработано * 100 / ВсегоЗаписей);
				Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонПрогресса, 
					ЗаписейОбработано, Окр(РазмерОбработано / 1024 / 1024), ВсегоЗаписей, ВсегоРазмерМб);
				ДлительныеОперации.СообщитьПрогресс(Процент, Текст);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла; 
	
	Если ЗначениеЗаполнено(АдресРезультата) И Ошибки.Количество() > 0 Тогда
		ПоместитьВоВременноеХранилище(Ошибки, АдресРезультата);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики обновления.

// Регистрирует на плане обмена ОбновлениеИнформационнойБазы объекты,
// для которых необходимо обновить записи в регистре.
//
Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВерсииФайлов.Ссылка
		|ИЗ
		|	Справочник.ВерсииФайлов КАК ВерсииФайлов
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.УдалитьДвоичныеДанныеФайлов КАК УдалитьДвоичныеДанныеФайлов
		|		ПО ВерсииФайлов.Ссылка = УдалитьДвоичныеДанныеФайлов.Файл
		|ГДЕ
		|	УдалитьДвоичныеДанныеФайлов.Файл ЕСТЬ NULL
		|	И ВерсииФайлов.ТипХраненияФайла = ЗНАЧЕНИЕ(Перечисление.ТипыХраненияФайлов.ВИнформационнойБазе)
		|
		|УПОРЯДОЧИТЬ ПО
		|	ВерсииФайлов.ДатаМодификацииУниверсальная УБЫВ";
	
	МассивСсылок = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, МассивСсылок);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УдалитьДвоичныеДанныеФайлов.Файл КАК Ссылка
	|ИЗ
	|	РегистрСведений.УдалитьДвоичныеДанныеФайлов КАК УдалитьДвоичныеДанныеФайлов
	|ГДЕ
	|	ТИПЗНАЧЕНИЯ(УдалитьДвоичныеДанныеФайлов.Файл) = &ТипФайла";
	
	Запрос.УстановитьПараметр("ТипФайла", ТипЗнч(Справочники.Файлы.ПустаяСсылка()));
	
	МассивСсылок = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, МассивСсылок);
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, "Справочник.ВерсииФайлов");
	Если Выборка.Количество() > 0 Тогда
		ПеренестиДвоичныеДанныеФайловВРегистрСведенийХранилищеФайлов(Выборка);
	КонецЕсли;
	
	Выборка = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, "Справочник.Файлы");
	Если Выборка.Количество() > 0 Тогда
		СоздатьНедостающиеВерсииФайлов(Выборка);
	КонецЕсли;
	
	ОбработкаЗавершена = ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, "Справочник.ВерсииФайлов")
		И ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, "Справочник.Файлы");
	
	Параметры.ОбработкаЗавершена = ОбработкаЗавершена;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПеренестиДвоичныеДанныеФайловВРегистрСведенийХранилищеФайлов(Выборка)
	
	ОбъектовОбработано = 0;
	ПроблемныхОбъектов = 0;
	
	Пока Выборка.Следующий() Цикл
		
		НачатьТранзакцию();
		Попытка
			
			БлокировкаДанных = Новый БлокировкаДанных;
			ЭлементБлокировкиДанных = БлокировкаДанных.Добавить("РегистрСведений.УдалитьХранимыеФайлыВерсий");
			ЭлементБлокировкиДанных.УстановитьЗначение("ВерсияФайла", Выборка.Ссылка);
			ЭлементБлокировкиДанных.Режим = РежимБлокировкиДанных.Разделяемый;
			БлокировкаДанных.Заблокировать();
			
			МенеджерЗаписиВерсииФайла = РегистрыСведений.УдалитьХранимыеФайлыВерсий.СоздатьМенеджерЗаписи();
			МенеджерЗаписиВерсииФайла.ВерсияФайла = Выборка.Ссылка;
			МенеджерЗаписиВерсииФайла.Прочитать();
			
			ДвоичныеДанные = МенеджерЗаписиВерсииФайла.ХранимыйФайл.Получить();
			// @skip-check query-in-loop - порционная обработка больших объемов данных. 
			ЗаписатьДвоичныеДанные(Выборка.Ссылка, ДвоичныеДанные);

			ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(Выборка.Ссылка);
			ОбъектовОбработано = ОбъектовОбработано + 1;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			// Если не удалось обработать какой-либо документ, повторяем попытку снова.
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать двоичные данные файла %1 по причине:
				|%2'"), 
				Выборка.Ссылка, ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), 
				УровеньЖурналаРегистрации.Предупреждение, Выборка.Ссылка.Метаданные(), Выборка.Ссылка, 
				ТекстСообщения);
		КонецПопытки;
		
	КонецЦикла;
	
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось обработать некоторые двоичные данные файла (пропущены): %1'"), 
			ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), 
			УровеньЖурналаРегистрации.Информация, Метаданные.Справочники.ВерсииФайлов,,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Обработана очередная порция двоичных данных файлов: %1'"),
				ОбъектовОбработано));
	КонецЕсли;
	
КонецПроцедуры

Процедура СоздатьНедостающиеВерсииФайлов(Выборка)
	
	ОбъектовОбработано = 0;
	ПроблемныхОбъектов = 0;
	
	Пока Выборка.Следующий() Цикл
		
		ФайлСсылка = Выборка.Ссылка; // СправочникСсылка.Файлы
		ПредставлениеСсылки = Строка(ФайлСсылка);
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.Файлы");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", ФайлСсылка);
		
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.УдалитьДвоичныеДанныеФайлов");
		ЭлементБлокировки.УстановитьЗначение("Файл", ФайлСсылка);
		
		НачатьТранзакцию();
		Попытка
			Блокировка.Заблокировать();
			
			ФайлОбъект = ФайлСсылка.ПолучитьОбъект();
			
			Если ФайлОбъект <> Неопределено Тогда
				
				Версия = Справочники.ВерсииФайлов.СоздатьЭлемент();
				Версия.УстановитьНовыйКод();
				
				НаборСвойств = "Автор,Владелец,ДатаМодификацииУниверсальная,ДатаСоздания,ИндексКартинки,
				|Наименование,ПометкаУдаления, ПутьКФайлу,Размер,Расширение,СтатусИзвлеченияТекста,
				|ТекстХранилище, ТипХраненияФайла, Том";
				
				ЗаполнитьЗначенияСвойств(Версия, ФайлОбъект, НаборСвойств);
				Версия.НомерВерсии = 1;
				Версия.Владелец = ФайлСсылка;
				
				ОбновлениеИнформационнойБазы.ЗаписатьОбъект(Версия);
				
				ФайлОбъект.ТекущаяВерсия = Версия.Ссылка;
				ОбновлениеИнформационнойБазы.ЗаписатьОбъект(ФайлОбъект);
				
				ДвоичныеДанныеФайлов = РегистрыСведений.УдалитьДвоичныеДанныеФайлов.СоздатьМенеджерЗаписи();
				ДвоичныеДанныеФайлов.Файл = ФайлСсылка;
				ДвоичныеДанныеФайлов.Прочитать();
				Если ДвоичныеДанныеФайлов.Выбран() Тогда
					// @skip-check query-in-loop - порционная обработка больших объемов данных. 
					ЗаписатьДвоичныеДанные(Версия.Ссылка, ДвоичныеДанныеФайлов.ДвоичныеДанныеФайла.Получить());
					ДвоичныеДанныеФайлов.Удалить();
				КонецЕсли;
				
			КонецЕсли;
			
			ОбъектовОбработано = ОбъектовОбработано + 1;
			ЗафиксироватьТранзакцию();
		Исключение
			
			ОтменитьТранзакцию();
			// Если не удалось обработать какой-либо файл, повторяем попытку снова.
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ОбновлениеИнформационнойБазы.ЗаписатьОшибкуВЖурналРегистрации(
				ФайлСсылка,
				ПредставлениеСсылки,
				ИнформацияОбОшибке());
			
		КонецПопытки;
		
	КонецЦикла;
	
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось обработать некоторые файлы (пропущены): %1'"), 
			ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,
			Метаданные.Справочники.ВерсииФайлов,,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Обработана очередная порция файлов: %1'"),
				ОбъектовОбработано));
	КонецЕсли;
	
КонецПроцедуры

Функция ЗаписьСуществует(Файл)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Файл", Файл);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	1 КАК Проверка
	|ИЗ
	|	РегистрСведений.ХранилищеФайлов КАК ХранилищеФайлов
	|ГДЕ
	|	ХранилищеФайлов.Файл = &Файл";
	
	Возврат Не Запрос.Выполнить().Пустой();
	
КонецФункции

#КонецОбласти


#КонецЕсли

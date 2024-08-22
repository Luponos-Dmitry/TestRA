///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных
Перем СтрокаСообщенияОбОшибке Экспорт;
Перем СтрокаСообщенияОбОшибкеЖР Экспорт;

Перем СообщенияОшибок; // Соответствие с предопределенными сообщениями ошибок обработки.
Перем ИмяОбъекта;		// имя объекта метаданных
Перем ИмяFTPСервера;		// Адрес FTP сервера - имя или ip адрес.
Перем КаталогНаFTPСервере;// Каталог на сервере, для хранения/получения сообщений обмена.

Перем ВременныйФайлСообщенияОбмена; // Временный файл сообщения обмена для выгрузки/загрузки данных.
Перем ВременныйКаталогСообщенийОбмена; // Временный каталог для сообщений обмена.

Перем ТаймаутОтправкиПолученияДанных; // Таймаут, используемый для FTP соединения при отправке и получении данных.
Перем ТаймаутПроверкиСоединения; // Таймаут, используемый для проверки соединения с FTP-сервером.

Перем ИдентификаторКаталога;
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Экспортные служебные процедуры и функции.

// Создает временный каталог в каталоге временных файлов пользователя операционной системы.
//
// Параметры:
//  Нет.
// 
//  Возвращаемое значение:
//    Булево - Истина - удалось выполнить функцию, Ложь - произошла ошибка.
// 
Функция ВыполнитьДействияПередОбработкойСообщения() Экспорт
	
	ИнициализацияСообщений();
	
	ИдентификаторКаталога = Неопределено;
	
	Возврат СоздатьВременныйКаталогСообщенийОбмена();
	
КонецФункции

// Выполняет отправку сообщения обмена на заданный ресурс из временного каталога сообщения обмена.
//
// Параметры:
//  Нет.
// 
//  Возвращаемое значение:
//    Булево - Истина - удалось выполнить функцию, Ложь - произошла ошибка.
// 
Функция ОтправитьСообщение() Экспорт
	
	ИнициализацияСообщений();
	
	Попытка
		Результат = ОтправитьСообщениеОбмена();
	Исключение
		Результат = Ложь;
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Получает сообщение обмена с заданного ресурса во временный каталог сообщения обмена.
//
// Параметры:
//  ПроверкаНаличия - Булево - Истина, если необходимо только проверить наличие сообщений обмена, без их загрузки.
// 
//  Возвращаемое значение:
//    Булево - Истина - удалось выполнить функцию, Ложь - произошла ошибка.
// 
Функция ПолучитьСообщение(ПроверкаНаличия = Ложь) Экспорт
	
	ИнициализацияСообщений();
	
	Попытка
		Результат = ПолучитьСообщениеОбмена(ПроверкаНаличия);
	Исключение
		Результат = Ложь;
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Удаляет временный каталог сообщений обмена после выполнения выгрузки или загрузки данных.
//
// Параметры:
//  Нет.
// 
//  Возвращаемое значение:
//    Булево - Истина
//
Функция ВыполнитьДействияПослеОбработкиСообщения() Экспорт
	
	ИнициализацияСообщений();
	
	УдалитьВременныйКаталогСообщенийОбмена();
	
	Возврат Истина;
	
КонецФункции

// Выполняет инициализацию свойств обработки начальными значениями и константами.
//
// Параметры:
//  Нет.
// 
Процедура Инициализация() Экспорт
	
	ИнициализацияСообщений();
	
	ИмяСервераИКаталогНаСервере = РазделитьFTPРесурсНаСерверИКаталог(СокрЛП(FTPСоединениеПуть));
	ИмяFTPСервера			= ИмяСервераИКаталогНаСервере.ИмяСервера;
	КаталогНаFTPСервере	= ИмяСервераИКаталогНаСервере.ИмяКаталога;
	
КонецПроцедуры

// Выполняет проверку возможности установки подключения к заданному ресурсу.
//
// Параметры:
//  Нет.
// 
//  Возвращаемое значение:
//    Булево - Истина - подключение может быть установлено; Ложь - нет.
//
Функция ПодключениеУстановлено() Экспорт
	
	// Возвращаемое значение функции.
	Результат = Истина;
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат Результат;
	КонецЕсли;
	
	ИнициализацияСообщений();
	
	Если ПустаяСтрока(FTPСоединениеПуть) Тогда
		
		ПолучитьСообщениеОбОшибке(101);
		Возврат Ложь;
		
	КонецЕсли;
	
	// Создаем файл во временном каталоге.
	ИмяВременногоФайлаПроверкиПодключения = ПолучитьИмяВременногоФайла("tmp");
	ИмяФайлаНаСторонеПриемника = ОбменДаннымиСервер.ИмяВременногоФайлаПроверкиПодключения();
	
	ЗаписьТекста = Новый ЗаписьТекста(ИмяВременногоФайлаПроверкиПодключения);
	ЗаписьТекста.ЗаписатьСтроку(ИмяФайлаНаСторонеПриемника);
	ЗаписьТекста.Закрыть();
	
	// Копируем файл на внешний ресурс из временного каталога.
	Результат = ВыполнитьКопированиеФайлаНаFTPСервер(ИмяВременногоФайлаПроверкиПодключения, ИмяФайлаНаСторонеПриемника, ТаймаутПроверкиСоединения);
	
	// Удаляем файл на внешнем ресурсе.
	Если Результат Тогда
		
		Результат = ВыполнитьУдалениеФайлаНаFTPСервере(ИмяФайлаНаСторонеПриемника, Истина);
		
	КонецЕсли;
	
	// Удаляем файл из временного каталога.
	УдалитьФайлы(ИмяВременногоФайлаПроверкиПодключения);
	
	Возврат Результат;
КонецФункции

///////////////////////////////////////////////////////////////////////////////
// Функции-свойства

// Функция-свойство: время изменения файла сообщения обмена.
//
// Возвращаемое значение:
//  Дата - время изменения файла сообщения обмена.
//
Функция ДатаФайлаСообщенияОбмена() Экспорт
	
	Результат = Неопределено;
	
	Если ТипЗнч(ВременныйФайлСообщенияОбмена) = Тип("Файл") Тогда
		
		Если ВременныйФайлСообщенияОбмена.Существует() Тогда
			
			Результат = ВременныйФайлСообщенияОбмена.ПолучитьВремяИзменения();
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Функция-свойство: полное имя файла сообщения обмена.
//
// Возвращаемое значение:
//  Строка - полное имя файла сообщения обмена.
//
Функция ИмяФайлаСообщенияОбмена() Экспорт
	
	Имя = "";
	
	Если ТипЗнч(ВременныйФайлСообщенияОбмена) = Тип("Файл") Тогда
		
		Имя = ВременныйФайлСообщенияОбмена.ПолноеИмя;
		
	КонецЕсли;
	
	Возврат Имя;
	
КонецФункции

// Функция-свойство: полное имя каталога сообщения обмена.
//
// Возвращаемое значение:
//  Строка - полное имя каталога сообщения обмена.
//
Функция ИмяКаталогаСообщенияОбмена() Экспорт
	
	Имя = "";
	
	Если ТипЗнч(ВременныйКаталогСообщенийОбмена) = Тип("Файл") Тогда
		
		Имя = ВременныйКаталогСообщенийОбмена.ПолноеИмя;
		
	КонецЕсли;
	
	Возврат Имя;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////
// Локальные служебные процедуры и функции.

Функция СоздатьВременныйКаталогСообщенийОбмена()
	
	// Создаем временный каталог для сообщений обмена.
	Попытка
		ИмяВременногоКаталога = ОбменДаннымиСервер.СоздатьВременныйКаталогСообщенийОбмена(ИдентификаторКаталога);
	Исключение
		ПолучитьСообщениеОбОшибке(4);
		ДополнитьСообщениеОбОшибке(ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат Ложь;
	КонецПопытки;
	
	ВременныйКаталогСообщенийОбмена = Новый Файл(ИмяВременногоКаталога);
	
	ИмяФайлаСообщения = ОбщегоНазначенияКлиентСервер.ПолучитьПолноеИмяФайла(ИмяКаталогаСообщенияОбмена(), ШаблонИмениФайлаСообщения + ".xml");
	
	ВременныйФайлСообщенияОбмена = Новый Файл(ИмяФайлаСообщения);
	
	Возврат Истина;
КонецФункции

Функция УдалитьВременныйКаталогСообщенийОбмена()
	
	Попытка
		Если Не ПустаяСтрока(ИмяКаталогаСообщенияОбмена()) Тогда
			УдалитьФайлы(ИмяКаталогаСообщенияОбмена());
			ВременныйКаталогСообщенийОбмена = Неопределено;
		КонецЕсли;
		
		Если Не ИдентификаторКаталога = Неопределено Тогда
			ОбменДаннымиСервер.ПолучитьФайлИзХранилища(ИдентификаторКаталога);
			ИдентификаторКаталога = Неопределено;
		КонецЕсли;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

Функция ОтправитьСообщениеОбмена()
	
	Результат = Истина;
	
	Расширение = ?(СжиматьФайлИсходящегоСообщения(), ".zip", ".xml");
	
	ИмяФайлаИсходящегоСообщения = ШаблонИмениФайлаСообщения + Расширение;
	
	Если СжиматьФайлИсходящегоСообщения() Тогда
		
		// Получаем имя для временного файла архива.
		ИмяВременногоФайлаАрхива = ОбщегоНазначенияКлиентСервер.ПолучитьПолноеИмяФайла(ИмяКаталогаСообщенияОбмена(), ШаблонИмениФайлаСообщения + ".zip");
		
		Попытка
			
			Архиватор = Новый ЗаписьZipФайла(ИмяВременногоФайлаАрхива, ПарольАрхиваСообщенияОбмена, НСтр("ru = 'Файл сообщения обмена'"));
			Архиватор.Добавить(ИмяФайлаСообщенияОбмена());
			Архиватор.Записать();
			
		Исключение
			
			Результат = Ложь;
			ПолучитьСообщениеОбОшибке(3);
			ДополнитьСообщениеОбОшибке(ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
			
		КонецПопытки;
		
		Архиватор = Неопределено;
		
		Если Результат Тогда
			
			// Выполняем проверку на максимально допустимый размер сообщения обмена.
			Если ОбменДаннымиСервер.РазмерСообщенияОбменаПревышаетДопустимый(ИмяВременногоФайлаАрхива, МаксимальныйДопустимыйРазмерСообщения()) Тогда
				ПолучитьСообщениеОбОшибке(108);
				Результат = Ложь;
			КонецЕсли;
			
		КонецЕсли;
		
		Если Результат Тогда
			
			// Копируем файл архива на FTP сервер в каталог обмена информацией.
			Если Не ВыполнитьКопированиеФайлаНаFTPСервер(ИмяВременногоФайлаАрхива, ИмяФайлаИсходящегоСообщения, ТаймаутОтправкиПолученияДанных) Тогда
				Результат = Ложь;
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		
		Если Результат Тогда
			
			// Выполняем проверку на максимально допустимый размер сообщения обмена.
			Если ОбменДаннымиСервер.РазмерСообщенияОбменаПревышаетДопустимый(ИмяФайлаСообщенияОбмена(), МаксимальныйДопустимыйРазмерСообщения()) Тогда
				ПолучитьСообщениеОбОшибке(108);
				Результат = Ложь;
			КонецЕсли;
			
		КонецЕсли;
		
		Если Результат Тогда
			
			// Копируем файл архива на FTP сервер в каталог обмена информацией.
			Если Не ВыполнитьКопированиеФайлаНаFTPСервер(ИмяФайлаСообщенияОбмена(), ИмяФайлаИсходящегоСообщения, ТаймаутОтправкиПолученияДанных) Тогда
				Результат = Ложь;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ПолучитьСообщениеОбмена(ПроверкаНаличия)
	
	ТаблицаФайловСообщенийОбмена = Новый ТаблицаЗначений;
	ТаблицаФайловСообщенийОбмена.Колонки.Добавить("Файл");
	ТаблицаФайловСообщенийОбмена.Колонки.Добавить("ВремяИзменения");
	
	Попытка
		FTPСоединение = ПолучитьFTPСоединение(ТаймаутОтправкиПолученияДанных);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ПолучитьСообщениеОбОшибке(102);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	ШаблонИмениФайлаСообщенияДляПоиска = СтрЗаменить(ШаблонИмениФайлаСообщения, "Message", "Message*");

	Попытка
		МассивНайденныхФайлов = FTPСоединение.НайтиФайлы(КаталогНаFTPСервере, ШаблонИмениФайлаСообщенияДляПоиска + ".*", Ложь);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ПолучитьСообщениеОбОшибке(104);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	Для Каждого ТекущийФайл Из МассивНайденныхФайлов Цикл
		
		// Проверяем нужное расширение.
		Если ((ВРег(ТекущийФайл.Расширение) <> ".ZIP")
			И (ВРег(ТекущийФайл.Расширение) <> ".XML")) Тогда
			
			Продолжить;
			
		// Проверяем что это файл, а не каталог.
		ИначеЕсли НЕ ТекущийФайл.ЭтоФайл() Тогда
			
			Продолжить;
			
		// Проверяем ненулевой размер файла.
		ИначеЕсли (ТекущийФайл.Размер() = 0) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		// Файл является требуемым сообщением обмена; добавляем его в таблицу.
		СтрокаТаблицы = ТаблицаФайловСообщенийОбмена.Добавить();
		СтрокаТаблицы.Файл           = ТекущийФайл;
		СтрокаТаблицы.ВремяИзменения = ТекущийФайл.ПолучитьВремяИзменения();
		
	КонецЦикла;
	
	Если ТаблицаФайловСообщенийОбмена.Количество() = 0 Тогда
		
		Если Не ПроверкаНаличия Тогда
			ПолучитьСообщениеОбОшибке(1);
		
			СтрокаСообщения = НСтр("ru = 'Каталог обмена информацией на сервере: ""%1""'");
			СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщения, КаталогНаFTPСервере);
			ДополнитьСообщениеОбОшибке(СтрокаСообщения);
			
			СтрокаСообщения = НСтр("ru = 'Имя файла сообщения обмена: ""%1"" или ""%2""'");
			СтрокаСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщения, ШаблонИмениФайлаСообщения + ".xml", ШаблонИмениФайлаСообщения + ".zip");
			ДополнитьСообщениеОбОшибке(СтрокаСообщения);
		КонецЕсли;
		
		Возврат Ложь;
		
	Иначе
		
		Если ПроверкаНаличия Тогда
			Возврат Истина;
		КонецЕсли;
		
		ТаблицаФайловСообщенийОбмена.Сортировать("ВремяИзменения Убыв");
		
		// Получаем из таблицы самый "свежий" файл сообщения обмена.
		ФайлВходящегоСообщения = ТаблицаФайловСообщенийОбмена[0].Файл;
		
		ФайлЗапакован = (ВРег(ФайлВходящегоСообщения.Расширение) = ".ZIP");
		
		РегистрыСведений.АрхивСообщенийОбменов.ПоместитьСообщениеВАрхив(УзелИнформационнойБазы, ФайлВходящегоСообщения.ПолноеИмя);
		
		Если ФайлЗапакован Тогда
			
			// Получаем имя для временного файла архива.
			ИмяВременногоФайлаАрхива = ОбщегоНазначенияКлиентСервер.ПолучитьПолноеИмяФайла(ИмяКаталогаСообщенияОбмена(), ШаблонИмениФайлаСообщения + ".zip");
			
			Попытка
				FTPСоединение.Получить(ФайлВходящегоСообщения.ПолноеИмя, ИмяВременногоФайлаАрхива);
			Исключение
				ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
				ПолучитьСообщениеОбОшибке(105);
				ДополнитьСообщениеОбОшибке(ТекстОшибки);
				Возврат Ложь;
			КонецПопытки;
			
			// Распаковываем временный файл архива.
			УспешноРаспаковано = ОбменДаннымиСервер.РаспаковатьZipФайл(ИмяВременногоФайлаАрхива, ИмяКаталогаСообщенияОбмена(), ПарольАрхиваСообщенияОбмена);
			
			Если Не УспешноРаспаковано Тогда
				ПолучитьСообщениеОбОшибке(2);
				Возврат Ложь;
			КонецЕсли;
			
			// Проверка на существование файла сообщения.
			Файл = Новый Файл(ИмяФайлаСообщенияОбмена());
			
			Если Не Файл.Существует() Тогда
				// Возможно, имя архива не соответствует имени файла внутри.
				СтруктураИмениФайлаАрхива = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(ФайлВходящегоСообщения.Имя,Ложь);
				СтруктураИмениФайлаСообщения = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(ИмяФайлаСообщенияОбмена(),Ложь);
				
				Если СтруктураИмениФайлаАрхива.ИмяБезРасширения <> СтруктураИмениФайлаСообщения.ИмяБезРасширения Тогда
					МассивРаспакованныхФайлов = НайтиФайлы(ИмяКаталогаСообщенияОбмена(), "*.xml", Ложь);
					Если МассивРаспакованныхФайлов.Количество() > 0 Тогда
						РаспакованныйФайл = МассивРаспакованныхФайлов[0];
						ПереместитьФайл(РаспакованныйФайл.ПолноеИмя,ИмяФайлаСообщенияОбмена());
					Иначе
						ПолучитьСообщениеОбОшибке(7);
						Возврат Ложь;
					КонецЕсли;
				Иначе
					ПолучитьСообщениеОбОшибке(7);
					Возврат Ложь;
				КонецЕсли;
				
			КонецЕсли;
			
		Иначе
			Попытка
				FTPСоединение.Получить(ФайлВходящегоСообщения.ПолноеИмя, ИмяФайлаСообщенияОбмена());
			Исключение
				ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
				ПолучитьСообщениеОбОшибке(105);
				ДополнитьСообщениеОбОшибке(ТекстОшибки);
				Возврат Ложь;
			КонецПопытки;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Процедура ПолучитьСообщениеОбОшибке(НомерСообщения)
	
	УстановитьСтрокуСообщенияОбОшибке(СообщенияОшибок[НомерСообщения]);
	
КонецПроцедуры

Процедура УстановитьСтрокуСообщенияОбОшибке(Знач Сообщение)
	
	Если Сообщение = Неопределено Тогда
		Сообщение = НСтр("ru = 'Внутренняя ошибка'");
	КонецЕсли;
	
	СтрокаСообщенияОбОшибке   = Сообщение;
	СтрокаСообщенияОбОшибкеЖР = ИмяОбъекта + ": " + Сообщение;
	
КонецПроцедуры

Процедура ДополнитьСообщениеОбОшибке(Сообщение)
	
	СтрокаСообщенияОбОшибкеЖР = СтрокаСообщенияОбОшибкеЖР + Символы.ПС + Сообщение;
	
КонецПроцедуры

// Переопределяемая функция, возвращает максимально допустимый размер
// сообщения, которое может быть отправлено.
// 
Функция МаксимальныйДопустимыйРазмерСообщения()
	
	Возврат FTPСоединениеМаксимальныйДопустимыйРазмерСообщения;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////
// Функции-свойства

Функция СжиматьФайлИсходящегоСообщения()
	
	Возврат FTPСжиматьФайлИсходящегоСообщения;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////
// Инициализация

Процедура ИнициализацияСообщений()
	
	СтрокаСообщенияОбОшибке   = "";
	СтрокаСообщенияОбОшибкеЖР = "";
	
КонецПроцедуры

Процедура ИнициализацияСообщенийОшибок()
	
	СообщенияОшибок = Новый Соответствие;
	
	// Общие коды ошибок
	СообщенияОшибок.Вставить(001, НСтр("ru = 'В каталоге обмена информацией не был обнаружен файл сообщения с данными.'"));
	СообщенияОшибок.Вставить(002, НСтр("ru = 'Ошибка при распаковке сжатого файла сообщения.'"));
	СообщенияОшибок.Вставить(003, НСтр("ru = 'Ошибка при сжатии файла сообщения обмена.'"));
	СообщенияОшибок.Вставить(004, НСтр("ru = 'Ошибка при создании временного каталога.'"));
	СообщенияОшибок.Вставить(005, НСтр("ru = 'Архив не содержит файл сообщения обмена.'"));
	
	// Коды ошибок, зависящие от вида транспорта.
	СообщенияОшибок.Вставить(101, НСтр("ru = 'Не задан путь на сервере.'"));
	СообщенияОшибок.Вставить(102, НСтр("ru = 'Ошибка инициализации подключения к FTP-серверу.'"));
	СообщенияОшибок.Вставить(103, НСтр("ru = 'Ошибка подключения к FTP-серверу, проверьте правильность задания пути и права доступа к ресурсу.'"));
	СообщенияОшибок.Вставить(104, НСтр("ru = 'Ошибка при поиске файлов на FTP-сервере.'"));
	СообщенияОшибок.Вставить(105, НСтр("ru = 'Ошибка при получении файла с FTP-сервера.'"));
	СообщенияОшибок.Вставить(106, НСтр("ru = 'Ошибка удаления файла на FTP-сервере, проверьте права доступа к ресурсу.'"));
	
	СообщенияОшибок.Вставить(108, НСтр("ru = 'Превышен допустимый размер сообщения обмена.'"));
	
	СообщенияОшибок.Вставить(109, НСтр("ru = 'Ошибка при попытке установить активное соединение с FTP-сервером. Попробуйте использовать пассивное соединение.'"));
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////
// Работа с FTP

Функция ПолучитьFTPСоединение(Таймаут)
	
	НастройкиFTP = ОбменДаннымиСервер.FTPНастройкиСоединения(Таймаут);
	НастройкиFTP.Сервер               = ИмяFTPСервера;
	НастройкиFTP.Порт                 = FTPСоединениеПорт;
	НастройкиFTP.ИмяПользователя      = FTPСоединениеПользователь;
	НастройкиFTP.ПарольПользователя   = FTPСоединениеПароль;
	НастройкиFTP.ПассивноеСоединение  = FTPСоединениеПассивноеСоединение;
	НастройкиFTP.ЗащищенноеСоединение = ОбменДаннымиСервер.ЗащищенноеСоединение(FTPСоединениеПуть);
	
	Возврат ОбменДаннымиСервер.FTPСоединение(НастройкиFTP);
	
КонецФункции

Функция ВыполнитьКопированиеФайлаНаFTPСервер(Знач ИмяФайлаИсточника, ИмяФайлаПриемника, Знач Таймаут)
	
	Перем КаталогНаСервере;
	
	СерверИКаталогНаСервере = РазделитьFTPРесурсНаСерверИКаталог(СокрЛП(FTPСоединениеПуть));
	КаталогНаСервере = СерверИКаталогНаСервере.ИмяКаталога;
	
	Попытка
		FTPСоединение = ПолучитьFTPСоединение(Таймаут);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ПолучитьСообщениеОбОшибке(102);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	Если Таймаут = ТаймаутПроверкиСоединения 
		И FTPСоединение.ПассивныйРежим 
		И Не FTPСоединениеПассивноеСоединение Тогда	
		ТекстОшибки = "";
		ПолучитьСообщениеОбОшибке(109);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);		
		Возврат Ложь;
	КонецЕсли;
	
	СоздатьКаталогПриНеобходимости(FTPСоединение, КаталогНаСервере);
	
	Попытка
		FTPСоединение.Записать(ИмяФайлаИсточника, КаталогНаСервере + ИмяФайлаПриемника);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ПолучитьСообщениеОбОшибке(103);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат Истина;
	КонецЕсли;
	
	Попытка
		МассивФайлов = FTPСоединение.НайтиФайлы(КаталогНаСервере, ИмяФайлаПриемника, Ложь);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ПолучитьСообщениеОбОшибке(104);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	Возврат МассивФайлов.Количество() > 0;
	
КонецФункции

Процедура СоздатьКаталогПриНеобходимости(FTPСоединение, КаталогНаСервере)
	
	Если КаталогНаСервере = "/" Тогда
		Возврат;
	КонецЕсли;
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		
		// При работе в сервисе, проверка наличия каталога - очень затратная операция.
		// Поэтому каждый раз используется СоздатьКаталог. 
		// Если каталог уже существует, то переходим в Исключение и ничего не делаем
		Попытка
			FTPСоединение.СоздатьКаталог(КаталогНаСервере);
		Исключение
			// Действий не требуется
		КонецПопытки;
		
	Иначе	
		
		МассивИмен = СтрРазделить(КаталогНаСервере, "/", Ложь);
		ИмяКаталога = "";
		
		Для Каждого Имя Из МассивИмен Цикл
		
			ИмяКаталога = ИмяКаталога + "/" + Имя;
		
			Если FTPСоединение.НайтиФайлы(ИмяКаталога).Количество() = 0 Тогда
				FTPСоединение.СоздатьКаталог(ИмяКаталога);
			КонецЕсли;
		
		КонецЦикла;
	
	КонецЕсли;
	
КонецПроцедуры

Функция ВыполнитьУдалениеФайлаНаFTPСервере(Знач ИмяФайла, ПроверкаПодключения = Ложь)
	
	Перем КаталогНаСервере;
	
	СерверИКаталогНаСервере = РазделитьFTPРесурсНаСерверИКаталог(СокрЛП(FTPСоединениеПуть));
	КаталогНаСервере = СерверИКаталогНаСервере.ИмяКаталога;
	
	Попытка
		FTPСоединение = ПолучитьFTPСоединение(ТаймаутПроверкиСоединения);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ПолучитьСообщениеОбОшибке(102);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);
		Возврат Ложь;
	КонецПопытки;
	
	Попытка
		FTPСоединение.Удалить(КаталогНаСервере + ИмяФайла);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ПолучитьСообщениеОбОшибке(106);
		ДополнитьСообщениеОбОшибке(ТекстОшибки);
		
		Если ПроверкаПодключения Тогда
			
			СообщениеОбОшибке = НСтр("ru = 'Не удалось проверить подключение с помощью тестового файла ""%1"".
			|Возможно, заданный каталог не существует или недоступен.
			|Рекомендуется также обратиться к документации по FTP-серверу для настройки поддержки имен файлов с кириллицей.'");
			СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СообщениеОбОшибке, ИмяФайла);
			ДополнитьСообщениеОбОшибке(СообщениеОбОшибке);
			
		КонецЕсли;
		
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

Функция РазделитьFTPРесурсНаСерверИКаталог(Знач ПолныйПуть)
	
	Результат = Новый Структура("ИмяСервера, ИмяКаталога");
	
	ПараметрыFTP = ОбменДаннымиСервер.FTPИмяСервераИПуть(ПолныйПуть);
	
	Результат.ИмяСервера  = ПараметрыFTP.Сервер;
	Результат.ИмяКаталога = ПараметрыFTP.Путь;
	
	Возврат Результат;
КонецФункции

#КонецОбласти

#Область Инициализация

ИнициализацияСообщений();
ИнициализацияСообщенийОшибок();

ВременныйКаталогСообщенийОбмена = Неопределено;
ВременныйФайлСообщенияОбмена    = Неопределено;

ИмяFTPСервера       = Неопределено;
КаталогНаFTPСервере = Неопределено;

ИмяОбъекта = НСтр("ru = 'Обработка: %1'");
ИмяОбъекта = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ИмяОбъекта, Метаданные().Имя);

ТаймаутОтправкиПолученияДанных = 12*60*60;
ТаймаутПроверкиСоединения = 10;

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
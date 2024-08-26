///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Проверка наличия активных соединений с информационной базой.
//
// Возвращаемое значение:
//  Булево       - Истина, если соединения есть,
//                 Ложь, если соединений нет.
//
Функция НаличиеАктивныхСоединений(СообщенияДляЖурналаРегистрации = Неопределено) Экспорт
	
	ВыполнитьПроверкуПравДоступа("Администрирование", Метаданные);
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	Возврат СоединенияИБ.КоличествоСеансовИнформационнойБазы(Ложь, Ложь) > 1;
КонецФункции

Процедура ЗаписатьСтатусОбновления(ПараметрыОбновления, СообщенияДляЖурналаРегистрации = Неопределено) Экспорт
	
	ВыполнитьПроверкуПравДоступа("Администрирование", Метаданные);
	
	КаталогСкрипта = "";
	Если Не ПустаяСтрока(ПараметрыОбновления.ИмяГлавногоФайлаСкрипта) Тогда 
		КаталогСкрипта = Лев(ПараметрыОбновления.ИмяГлавногоФайлаСкрипта, СтрДлина(ПараметрыОбновления.ИмяГлавногоФайлаСкрипта) - 10);
	КонецЕсли;
	ПараметрыОбновления.КаталогСкрипта = КаталогСкрипта;
	
	ОбновлениеКонфигурации.ЗаписатьСтатусОбновления(
		ПараметрыОбновления,
		СообщенияДляЖурналаРегистрации);
	
КонецПроцедуры

Функция ТекстыМакетов(СообщенияДляЖурналаРегистрации, ИнтерактивныйРежим, ВыполнитьОтложенныеОбработчики, ЭтоОтложенноеОбновление) Экспорт
	
	ВыполнитьПроверкуПравДоступа("Администрирование", Метаданные);
	
	ТекстыМакетов = Новый Структура;
	ТекстыМакетов.Вставить("ДопФайлОбновленияКонфигурации");
	ТекстыМакетов.Вставить(?(ИнтерактивныйРежим, "ЗаставкаОбновленияКонфигурации", "НеинтерактивноеОбновлениеКонфигурации"));
	
	Если ЭтоОтложенноеОбновление Тогда
		ТекстыМакетов.Вставить("СкриптСозданияЗадачиПланировщикаЗадач");
	КонецЕсли;
	
	ТекстыМакетов.Вставить("СкриптУдаленияПатчей");
	
	Для Каждого СвойстваМакета Из ТекстыМакетов Цикл
		ТекстыМакетов[СвойстваМакета.Ключ] = Обработки.УстановкаОбновлений.ПолучитьМакет(СвойстваМакета.Ключ).ПолучитьТекст();
	КонецЦикла;
	
	Если ИнтерактивныйРежим Тогда
		ТекстыМакетов.ЗаставкаОбновленияКонфигурации = СформироватьТекстЗаставки(ТекстыМакетов.ЗаставкаОбновленияКонфигурации); 
	КонецЕсли;
	
	// Файл обновления конфигурации: main.js.
	ШаблонСкрипта = Обработки.УстановкаОбновлений.ПолучитьМакет("МакетФайлаОбновленияКонфигурации");
	
	ОбластьПараметров = ШаблонСкрипта.ПолучитьОбласть("ОбластьПараметров");
	ОбластьПараметров.УдалитьСтроку(1);
	ОбластьПараметров.УдалитьСтроку(ОбластьПараметров.КоличествоСтрок());
	Если СтрНачинаетсяС(ОбластьПараметров.ПолучитьСтроку(ОбластьПараметров.КоличествоСтрок()), "#") Тогда
		ОбластьПараметров.УдалитьСтроку(ОбластьПараметров.КоличествоСтрок());
	КонецЕсли;
	ТекстыМакетов.Вставить("ОбластьПараметров", ОбластьПараметров.ПолучитьТекст());
	
	ОбластьОбновленияКонфигурации = ШаблонСкрипта.ПолучитьОбласть("ОбластьОбновленияКонфигурации");
	ОбластьОбновленияКонфигурации.УдалитьСтроку(1);
	ОбластьОбновленияКонфигурации.УдалитьСтроку(ОбластьОбновленияКонфигурации.КоличествоСтрок());
	ТекстыМакетов.Вставить("МакетФайлаОбновленияКонфигурации", ОбластьОбновленияКонфигурации.ПолучитьТекст());
	
	// Запись накопленных событий ЖР.
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СообщенияДляЖурналаРегистрации);
	ВыполнитьОтложенныеОбработчики = ОбновлениеКонфигурации.ВыполнитьОтложенныеОбработчики();
	
	СообщенияСкриптов = СообщенияСкриптов();
	Для Каждого СвойстваМакета Из ТекстыМакетов Цикл
		ТекстыМакетов[СвойстваМакета.Ключ] = ПодставитьПараметрыВТекст(ТекстыМакетов[СвойстваМакета.Ключ], СообщенияСкриптов);
	КонецЦикла;
	
	Возврат ТекстыМакетов;
	
КонецФункции

Функция СформироватьТекстЗаставки(Знач ШаблонТекста)
	
	ПараметрыТекста = Новый Соответствие;
	ПараметрыТекста["[ЗаголовокЗаставки]"] = НСтр("ru = 'Обновление конфигурации ""1С:Предприятие""...'");
	ПараметрыТекста["[ТекстЗаставки]"] = НСтр("ru = 'Пожалуйста, подождите.
		|<br/> Выполняется обновление конфигурации.'");
	
	ПараметрыТекста["[Шаг1Инициализация]"] = НСтр("ru = 'Инициализация'");
	ПараметрыТекста["[Шаг2ЗавершениеРаботы]"] = НСтр("ru = 'Завершение работы пользователей'");
	ПараметрыТекста["[Шаг3СозданиеРезервнойКопии]"] = НСтр("ru = 'Создание резервной копии информационной базы'");
	ПараметрыТекста["[Шаг4ОбновлениеКонфигурации]"] = НСтр("ru = 'Обновление конфигурации информационной базы'");
	ПараметрыТекста["[Шаг4ЗагрузкаРасширений]"] = НСтр("ru = 'Обновление расширений информационной базы'");
	ПараметрыТекста["[Шаг5ОбновлениеИБ]"] = НСтр("ru = 'Выполнение обработчиков обновления'");
	ПараметрыТекста["[Шаг6ОтложенноеОбновление]"] = НСтр("ru = 'Выполнение отложенных обработчиков обновления'");
	ПараметрыТекста["[Шаг7СжатиеТаблиц]"] = НСтр("ru = 'Сжатие таблиц информационной базы'");
	ПараметрыТекста["[Шаг8РазрешениеПодключений]"] = НСтр("ru = 'Разрешение подключения новых соединений'");
	ПараметрыТекста["[Шаг9Завершение]"] = НСтр("ru = 'Завершение'");
	ПараметрыТекста["[Шаг10Восстановление]"] = НСтр("ru = 'Восстановление информационной базы'");
	ПараметрыТекста["[Шаг11УдалениеПатчей]"] = НСтр("ru = 'Удаление исправлений (патчей)'");
	
	ПараметрыТекста["[Шаг41Загрузка]"] = НСтр("ru = 'Загрузка файла обновления в основную базу'");
	ПараметрыТекста["[Шаг42ОбновлениеКонфигурации]"] = НСтр("ru = 'Обновление конфигурации информационной базы'");
	ПараметрыТекста["[Шаг43ОбновлениеИБ]"] = НСтр("ru = 'Выполнение обработчиков обновления'");
	
	ПараметрыТекста["[ПроцессПрерван]"] = НСтр("ru = 'Внимание: процесс обновления был прерван, и информационная база осталась заблокированной.'");
	ПараметрыТекста["[ПроцессПрерванПодсказка]"] = НСтр("ru = 'Для разблокирования информационной базы воспользуйтесь консолью кластера серверов или запустите ""1С:Предприятие"".'");
	
	ПараметрыТекста["[НаименованиеПродукта]"] = НСтр("ru = '1С:ПРЕДПРИЯТИЕ 8.3'");
	ПараметрыТекста["[Копирайт]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = '© ООО ""1С-Софт"", 1996-%1'"), Формат(Год(ТекущаяДатаСеанса()), "ЧГ=0"));
	
	Возврат ПодставитьПараметрыВТекст(ШаблонТекста, ПараметрыТекста);
	
КонецФункции

Функция ПодставитьПараметрыВТекст(Знач Текст, Знач ПараметрыТекста)
	
	Результат = Текст;
	Для каждого ПараметрТекста Из ПараметрыТекста Цикл
		Результат = СтрЗаменить(Результат, ПараметрТекста.Ключ, ПараметрТекста.Значение);
	КонецЦикла;
	Возврат Результат; 
	
КонецФункции

Процедура СохранитьНастройкиОбновленияКонфигурации(Настройки) Экспорт
	ВыполнитьПроверкуПравДоступа("Администрирование", Метаданные);
	ОбновлениеКонфигурации.СохранитьНастройкиОбновленияКонфигурации(Настройки);
КонецПроцедуры

Процедура ОбновитьИсправленияИзСкрипта(НовыеИсправления, УдаляемыеИсправления) Экспорт // АПК:557 для вызова из скрипта
	ОбновлениеКонфигурации.ОбновитьИсправленияИзСкрипта(НовыеИсправления, УдаляемыеИсправления);
КонецПроцедуры

Функция КаталогСкрипта() Экспорт
	
	Возврат ОбновлениеКонфигурации.КаталогСкрипта();
	
КонецФункции

// АПК:299-выкл для использования из скрипта обновления.
// АПК:557-выкл для использования из скрипта обновления.
//
Процедура УдалитьИсправленияИзСкрипта() Экспорт
	
	ТекстСообщения = НСтр("ru = 'Начато удаление исправлений до запуска обновления приложения.'");
	ЗаписьЖурналаРегистрации(ОбновлениеКонфигурации.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,,, ТекстСообщения);
	
	ВсеРасширения = РасширенияКонфигурации.Получить();
	Для Каждого Расширение Из ВсеРасширения Цикл
		Если Не ОбновлениеКонфигурации.ЭтоИсправление(Расширение) Тогда
			Продолжить;
		КонецЕсли;
		Попытка
			Расширение.Удалить();
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось удалить исправление ""%1"" по причине:
				           |
				           |%2'"), Расширение.Имя, ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Исправления.Удаление'", ОбщегоНазначения.КодОсновногоЯзыка())
				, УровеньЖурналаРегистрации.Ошибка,,, ТекстОшибки);
		КонецПопытки;
	КонецЦикла;
	
	ТекстСообщения = НСтр("ru = 'Удаление исправлений завершено.'");
	ЗаписьЖурналаРегистрации(ОбновлениеКонфигурации.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,,, ТекстСообщения);
	
КонецПроцедуры
// АПК:299-вкл
// АПК:557-вкл

Функция СообщенияСкриптов()
	
	Сообщения = Новый Соответствие;
		
	// Сообщения в макетах МакетФайлаОбновленияКонфигурации, НеинтерактивноеОбновлениеКонфигурации, ЗаставкаОбновленияКонфигурации
	Сообщения["[СообщениеНачалоЗапуска]"] = НСтр("ru = 'Запускается: {0}; параметры: {1}; окно: {2}; ожидание: {3}'");
	Сообщения["[СообщениеДеталиИсключения]"] = НСтр("ru = 'Исключение при запуске приложения: {0}, {1}'");
	Сообщения["[СообщениеРезультатЗапуска]"] = НСтр("ru = 'Код возврата: {0}'");
	Сообщения["[СообщениеПутьКФайлуСкрипта]"] = НСтр("ru = 'Файл скрипта: {0}'");
	Сообщения["[СообщениеСчетчикФайловОбновления]"] = НСтр("ru = 'Количество файлов обновления: {0}'");
	Сообщения["[СообщениеВосстановлениеБазы]"] = НСтр("ru = 'Восстановление ИБ из временного архива'");
	Сообщения["[СообщениеНачалоСеансаСоединенияСБазой]"] = НСтр("ru = 'Начат сеанс внешнего соединения с ИБ'");
	Сообщения["[СообщениеУдалениеЗадачиПланировщика]"] = НСтр("ru = 'Удаление задачи планировщика задач: {0}'");
	Сообщения["[СообщениеОтказУдаленияЗадачиПланировщика]"] = НСтр("ru = 'Задача из планировщика задач не была удалена по причине: {0}'");
	Сообщения["[СообщениеОтказСоединенияСБазой]"] = НСтр("ru = 'Исключение при создании COM-соединения: {0}, {1}'");
	Сообщения["[СообщениеВызовЗавершитьОбновление]"] = "ОбновлениеКонфигурации.ЗавершитьОбновление" + "({0}, {1}, {2})";
	Сообщения["[СообщениеОтказПриВызовеЗавершитьОбновление]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Исключение при вызове %1: {0}, {1}'"), "ОбновлениеКонфигурации.ЗавершитьОбновление");
	Сообщения["[СообщениеРезультатОбновленияБазы]"] = НСтр("ru = 'Обновление информационной базы завершилось успешно'");
	Сообщения["[СообщениеОтказОбновленияБазы]"] = НСтр("ru = 'Непредвиденная ситуация при обновлении информационной базы'");
	Сообщения["[СообщениеПараметрыБазы]"] = НСтр("ru = 'Параметры информационной базы: {0}.'");
	Сообщения["[СообщениеОтказЛогирования]"] = НСтр("ru = 'Исключение при записи журнала: {0}, {1}'");
	Сообщения["[СообщениеОбновлениеЛогирование1С]"] = НСтр("ru = 'Протокол обновления сохранен в журнал регистрации.'");
	Сообщения["[СообщениеКопированиеБазы]"] = НСтр("ru = '\r\n\Выполняется копирование из:\r\n\{0}\r\n\в:\r\n\{1}'");
	Сообщения["[СообщениеФайлБазыНеСуществует]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Файл базы данных %1 не существует по пути: {0}'"), "1Cv8.1CD");
	Сообщения["[СообщениеКаталогРезервнойКопииБазыНеСуществует]"] = НСтр("ru = 'Папки для сохранения резервной копии не существует: {0}'");
	Сообщения["[СообщениеПараметрыФайлаРезервнойКопии]"] = НСтр("ru = '\r\n\Файл резервной копии уже существует: {0}\r\n\Создан: {1}\r\n\Последнее обращение: {2}\r\n\Последнее изменение: {3}\r\n\Размер: {4}\r\n\Тип: {5}\r\n\Атрибуты:\r\n\{6}'");
	Сообщения["[СообщениеДискНеСуществует]"] = НСтр("ru = '\r\n\Диск не найден по пути {0}\r\n\Исключение: {1}, {2}'");
	Сообщения["[СообщениеДискНедоступен]"] = НСтр("ru = 'Диск недоступен по пути {0}'");
	Сообщения["[СообщениеДисковогоПространстваДостаточно]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Доступно на диске {0}: {1} Mb\r\n\Размер файла %1: {2} Mb\r\n\Тип диска: {3}'"), "1Cv8.1CD");
	Сообщения["[СообщениеДисковогоПространстваНедостаточно]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = '\r\n\Недостаточно свободного места для создания резервной копии.\r\n\Освободите место или укажите папку на другом диске.\r\n\Требуется: {0} Mb\r\n\Доступно на диске {1}: {2} Mb\r\n\Размер файла %1: {3} Mb\r\n\Тип диска: {4}'"), "1Cv8.1CD");
	Сообщения["[СообщениеРезультатСозданияРезервнойКопииБазы]"] = НСтр("ru = 'Резервная копия базы создана'");
	Сообщения["[СообщениеОтказСозданияРезервнойКопииБазыПодробно]"] = НСтр("ru = 'Исключение при создании резервной копии базы: {0}, {1}'");
	Сообщения["[СообщениеРезультатВосстановленияБазы]"] = НСтр("ru = 'База данных восстановлена из резервной копии'");
	Сообщения["[СообщениеОтказВосстановленияБазыПодробно]"] = НСтр("ru = 'Исключение при восстановлении базы из резервной копии: {0}, {1}.'");
	Сообщения["[СообщениеВызовРазрешитьРаботуПользователей]"] = "СоединенияИБ.РазрешитьРаботуПользователей";
	Сообщения["[СообщениеОтказВызоваРазрешитьРаботуПользователей]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Исключение при вызове %1: {0}, {1}'"), "СоединенияИБ.РазрешитьРаботуПользователей");
	Сообщения["[СообщениеОтказОбновленияИсправлений]"] = НСтр("ru = 'Не удалось обновить исправления конфигурации. Подробности см. в предыдущей записи.'");
	Сообщения["[СообщениеОтказВызоваОбновитьИсправленияИзСкрипта]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Исключение при вызове %1: {0}, {1}'"), "ОбновлениеКонфигурацииВызовСервера.ОбновитьИсправленияИзСкрипта");
	Сообщения["[СообщениеВызовВыполнитьОбновлениеИнформационнойБазы]"] = "ОбновлениеИнформационнойБазыВызовСервера.ВыполнитьОбновлениеИнформационнойБазы" + "({0})";
	Сообщения["[СообщениеОтказВызоваВыполнитьОбновлениеИнформационнойБазы]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Исключение при вызове %1: {0}, {1}.'"), "ОбновлениеИнформационнойБазыВызовСервера.ВыполнитьОбновлениеИнформационнойБазы");
	Сообщения["[СообщениеОтказОбновленияБазыОбщее]"] = НСтр("ru = 'Не удалось обновить информационную базу по причине:'");
	Сообщения["[СообщениеБлокировкаБазы]"] = НСтр("ru = 'в связи с необходимостью обновления конфигурации'");
	Сообщения["[СообщениеОтказЗавершенияРаботыПользователей]"] = НСтр("ru = 'Попытка завершения работы пользователей завершилась безуспешно: отменена блокировка ИБ.'");
	Сообщения["[СообщениеОтменаБлокировкиРаботыПользователей]"] = НСтр("ru = 'Исключение при завершении работы пользователей: {0}, {1}'");
	Сообщения["[СообщениеКонецСеансаСоединенияСБазой]"] = НСтр("ru = 'Завершен сеанс внешнего соединения с ИБ'");
	Сообщения["[СообщениеБлокировкаРаботыПользователейЛогирование]"] = НСтр("ru = 'Установка блокировки сеансов в связи с необходимостью обновления конфигурации'");
	Сообщения["[СообщениеБлокировкаРаботыПользователей]"] = НСтр("ru = 'в связи с необходимостью обновления конфигурации'");
	Сообщения["[СообщениеСчетчикСеансовБазы]"] = НСтр("ru = 'Количество сеансов информационной базы: {0}'");
	Сообщения["[СообщениеРезультатБлокировкиСеансов]"] = НСтр("ru = 'Блокировка начала сеансов установлена: {0}'");
	Сообщения["[СообщениеСчетчикЗависшихСеансовБазы]"] = НСтр("ru = 'Количество зависших сеансов информационной базы: {0}, попытка № {1}'");
	Сообщения["[СообщениеВызовВыполнитьОтложенноеОбновлениеСейчас]"] = "ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОтложенноеОбновлениеСейчас" + "()";
	Сообщения["[СообщениеОтказВызоваВыполнитьОтложенноеОбновлениеСейчас]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Исключение при вызове %1: {0}, {1}.'"), "ОбновлениеИнформационнойБазыСлужебный.ВыполнитьОтложенноеОбновлениеСейчас");
	Сообщения["[СообщениеОтказВызоваУдалитьИсправленияИзСкрипта]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Исключение при вызове %1: {0}, {1}.'"), "ОбновлениеКонфигурацииВызовСервера.УдалитьИсправленияИзСкрипта");
	Сообщения["[СообщениеОтказУдаленияИсправлений]"] = НСтр("ru = 'Не удалось удалить исправления конфигурации. Подробности см. в предыдущей записи.'");
	Сообщения["[СообщениеПараметрыCOMСоединителя]"] = НСтр("ru = 'Используется COM-соединение: {0}'");
	Сообщения["[СообщениеОтказОбновленияБазыИзФайла]"] = НСтр("ru = 'Не удалось обновить по файлу, возможно конфигурация не находится на поддержке, попытка загрузки конфигурации.'");
	Сообщения["[СообщениеЗаставкиОшибкаШага]"] = НСтр("ru = 'Завершение с ошибкой. Код ошибки: {0}. Подробности см. в предыдущей записи.'");
	Сообщения["[СообщениеИнициализация]"] = НСтр("ru = 'Инициализация'");
	Сообщения["[СообщениеЗавершениеРаботыПользователей]"] = НСтр("ru = 'Завершение работы пользователей'");
	Сообщения["[СообщениеСозданиеРезервнойКопииБазы]"] = НСтр("ru = 'Создание резервной копии информационной базы'");
	Сообщения["[СообщениеВыполнениеОтложенныхОбработчиковОбновления]"] = НСтр("ru = 'Выполнение отложенных обработчиков обновления'");
	Сообщения["[СообщениеОбновлениеКонфигурации]"] = НСтр("ru = 'Обновление конфигурации информационной базы'");
	Сообщения["[СообщениеЗагрузкаРасширений]"] = НСтр("ru = 'Обновление расширений информационной базы'");
	Сообщения["[СообщениеЗагрузкаФайлаОбновлений]"] = НСтр("ru = 'Загрузка файла обновления в основную базу ({0}/{1})'");
	Сообщения["[СообщениеПараметрыОбновленияКонфигурации]"] = НСтр("ru = 'Обновление конфигурации информационной базы ({0}/{1})'");
	Сообщения["[СообщениеВыполнениеОбработчиковОбновления]"] = НСтр("ru = 'Выполнение обработчиков обновления ({0}/{1})'");
	Сообщения["[СообщениеРазрешениеПодключений]"] = НСтр("ru = 'Разрешение подключений новых соединений'");
	Сообщения["[СообщениеЗавершениеОбновления]"] = НСтр("ru = 'Завершение'");
	
	// Сообщения в макете СкриптУдаленияПатчей
	Сообщения["[СообщениеОтказИнициализации]"] = НСтр("ru = 'Переменные не инициализированы'");
	Сообщения["[СообщениеСозданиеОбъектаCOMСоединителя]"] = НСтр("ru = 'Создание объекта COM-соединителя...'");
	Сообщения["[СообщениеОтказСозданияОбъектаCOMСоединителя]"] = НСтр("ru = 'Не удалось создать объект COM-соединителя:'");
	Сообщения["[СообщениеУстановкаСоединенияСБазой]"] = НСтр("ru = 'Установка соединения с'");
	Сообщения["[СообщениеОтказСоединенияСБазойОбщее]"] = НСтр("ru = 'Не удалось установить соединение с'");
	Сообщения["[СообщениеОсновноеСобытие]"] = НСтр("ru = 'Удаление исправлений (патчей)'");
	Сообщения["[СообщениеВызовУдалитьИсправленияИзСкрипта]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Вызов %1...'"), "ОбновлениеКонфигурацииВызовСервера.УдалитьИсправленияИзСкрипта");
	Сообщения["[СообщениеВызовОбновитьИсправленияИзСкрипта]"] = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Вызов %1...'"), "ОбновлениеКонфигурацииВызовСервера.ОбновитьИсправленияИзСкрипта");
	Сообщения["[СообщениеОшибка]"] = НСтр("ru = ': Ошибка в конфигурации:'") + Символы.НПП;
	Сообщения["[СообщениеВажность]"] = НСтр("ru = 'Обязательная'");
	
	Возврат Сообщения;
	
КонецФункции

Функция ВерсииТребующиеУспешногоОбновления(ФайлыОбновления) Экспорт
	
	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("Версия");
	Таблица.Колонки.Добавить("ВесВерсии");
	Таблица.Колонки.Добавить("Обязательная");
	
	Если ФайлыОбновления.Количество() < 2 Тогда
		Возврат Новый Массив;
	КонецЕсли;
	
	Для Каждого Сведения Из ФайлыОбновления Цикл
		ОписаниеОбновления = Новый ОписаниеОбновленияКонфигурации(Сведения.ДвоичныеДанные);
		
		Строка = Таблица.Добавить();
		Строка.Версия       = ОписаниеОбновления.ПолучаемаяКонфигурация.Версия;
		Строка.ВесВерсии    = ВесВерсии(Строка.Версия);
		Строка.Обязательная = Сведения.Обязательная;
	КонецЦикла;
	
	Версии = Новый Массив;
	Таблица.Сортировать("ВесВерсии Возр");
	ПоследняяСтрока = Таблица[Таблица.Количество() - 1];
	Для Каждого СтрокаТаблицы Из Таблица Цикл
		Если Не СтрокаТаблицы.Обязательная Тогда
			Продолжить;
		КонецЕсли;
		
		Если СтрокаТаблицы = ПоследняяСтрока Тогда
			Продолжить; // Последнюю версию не учитываем
		КонецЕсли;
		
		Версии.Добавить(СтрокаТаблицы.Версия);
	КонецЦикла;
	
	Возврат Версии;
	
КонецФункции

Функция ВесВерсии(Версия)
	
	ВерсияЧастями = СтрРазделить(Версия, ".");
	
	Возврат 0
		+ Число(ВерсияЧастями[0]) * 1000000000000
		+ Число(ВерсияЧастями[1]) * 100000000
		+ Число(ВерсияЧастями[2]) * 10000
		+ Число(ВерсияЧастями[3]);
	
КонецФункции

Функция ПараметрыОбновления() Экспорт
	
	ПараметрыОбновления = Новый Структура;
	ПараметрыОбновления.Вставить("ИмяАдминистратораОбновления", Неопределено);
	ПараметрыОбновления.Вставить("ОбновлениеЗапланировано", Ложь);
	ПараметрыОбновления.Вставить("ОбновлениеВыполнено", Ложь);
	ПараметрыОбновления.Вставить("РезультатОбновленияКонфигурации", Неопределено);
	ПараметрыОбновления.Вставить("КаталогСкрипта", "");
	ПараметрыОбновления.Вставить("ИмяГлавногоФайлаСкрипта", "");
	ПараметрыОбновления.Вставить("РезультатУстановкиПатчей", Неопределено);
	ПараметрыОбновления.Вставить("ВерсииТребующиеУспешногоОбновления", Неопределено);
	
	Возврат ПараметрыОбновления;
	
КонецФункции

#КонецОбласти

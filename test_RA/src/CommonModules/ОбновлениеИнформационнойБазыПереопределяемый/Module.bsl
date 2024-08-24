///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Позволяет задать общие настройки подсистемы, в том числе, список объектов начального заполнения, тексты сообщений для
// пользователя и другое.
// 
// Параметры:
//  Параметры - Структура:
//    * ПоясненияДляРезультатовОбновления - Строка - текст подсказки, указывающий путь
//                                          к форме "Результаты обновления приложения".
//    * ПараметрыСообщенияОНевыполненныхОтложенныхОбработчиках - Структура - сообщение о
//                                          наличии невыполненных отложенных обработчиков обновления
//                                          на прошлую версию при попытке обновления:
//       * ТекстСообщения                 - Строка - текст сообщения, выводимый пользователю. По умолчанию
//                                          текст сообщения построен с учетом того, что обновление можно
//                                          продолжить, т.е. параметр ЗапрещатьПродолжение = Ложь.
//       * КартинкаСообщения              - Картинка - картинка, выводимая слева от сообщения.
//       * ЗапрещатьПродолжение           - Булево - если Истина, продолжить обновление будет невозможно. По умолчанию Ложь.
//    * РасположениеОписанияИзмененийПрограммы - Строка - описывает расположение команды, по которой можно
//                                          открыть форму с описанием изменений в новой версии программы.
//    * МногопоточноеОбновление           - Булево - если Истина, то в один момент времени могут выполняться сразу
//                                          несколько обработчиков обновления. По умолчанию - Ложь.
//                                          Это влияет как на количество потоков выполнения обработчиков обновления,
//                                          так и количество потоков регистрации данных для обновления.
//                                          ВАЖНО: перед включением ознакомьтесь с документацией.
//    * КоличествоПотоковОбновленияИнформационнойБазыПоУмолчанию - Строка - количество потоков отложенного обновления
//                                          используемое, когда не задано значение для константы
//                                          КоличествоПотоковОбновленияИнформационнойБазы. По умолчанию равно 1.
//   * ОбъектыСНачальнымЗаполнением - Массив - объекты, содержащие в модуле менеджере код начального заполнения
//                                          в процедуре ПриНачальномЗаполненииЭлементов.
//
Процедура ПриОпределенииНастроек(Параметры) Экспорт
	
	
	
КонецПроцедуры

// Вызывается перед процедурами-обработчиками обновления данных ИБ.
// Здесь можно разместить любую нестандартную логику обновления данных - например,
// иначе проинициализировать сведения о версиях тех или иных подсистем
// с помощью ОбновлениеИнформационнойБазы.ВерсияИБ, ОбновлениеИнформационнойБазы.УстановитьВерсиюИБ,
// и ОбновлениеИнформационнойБазы.ЗарегистрироватьНовуюПодсистему.
//
// Пример:
//  Для того чтобы отменить штатную процедуру перехода с другой программы, регистрируем 
//  сведения о том, что основная конфигурации уже актуальной версии:
//  ВерсииПодсистем = ОбновлениеИнформационнойБазы.ВерсииПодсистем();
//  Если ВерсииПодсистем.Количество() > 0 И ВерсииПодсистем.Найти(Метаданные.Имя, "ИмяПодсистемы") = Неопределено Тогда
//    ОбновлениеИнформационнойБазы.ЗарегистрироватьНовуюПодсистему(Метаданные.Имя, Метаданные.Версия);
//  КонецЕсли;
//
Процедура ПередОбновлениемИнформационнойБазы() Экспорт
	
КонецПроцедуры

// Вызывается после завершения обновления данных ИБ.
// В зависимости от тех или иных условий можно отключить штатное открытие формы
// с описанием изменений в новой версии программы при первом входе в нее (после обновления),
// а также выполнить другие действия.
//
// Не рекомендуется выполнять в данной процедуре какую-либо обработку данных.
// Такие процедуры следует оформлять штатными обработчиками обновления, выполняемыми на каждую версию "*".
// 
// Параметры:
//   ПредыдущаяВерсияИБ     - Строка - версия до обновления. "0.0.0.0" для "пустой" ИБ.
//   ТекущаяВерсияИБ        - Строка - версия после обновления. Как правило, соответствует Метаданные.Версия.
//   ИтерацииОбновления     - Массив - массив структур, описывающих сведения об обновлении каждой
//                                     библиотеки и конфигурации, с ключами:
//       * Подсистема              - Строка - имя библиотеки или конфигурации.
//       * Версия                  - Строка - например, "2.1.3.39". Номер версии библиотеки (конфигурации).
//       * ЭтоОсновнаяКонфигурация - Булево - Истина, если это основная конфигурация, а не библиотека.
//       * Обработчики             - ТаблицаЗначений - все обработчики обновления библиотеки, описание колонок
//                                   см. в ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления.
//       * ВыполненныеОбработчики  - ДеревоЗначений - выполненные обработчики обновления, сгруппированные по
//                                   библиотеке и номеру версии, описание колонок
//                                   см. в ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления.
//       * ИмяОсновногоСерверногоМодуля - Строка - имя модуля библиотеки (конфигурации), который предоставляет
//                                        основные сведения о ней: имя, версия и т.д.
//       * ОсновнойСерверныйМодуль      - ОбщийМодуль - общий модуль библиотеки (конфигурации), который предоставляет
//                                        основные сведения о ней: имя, версия и т.д.
//       * ПредыдущаяВерсия             - Строка - например, "2.1.3.30". Номер версии библиотеки (конфигурации) до обновления.
//   ВыводитьОписаниеОбновлений - Булево - если установить Ложь, то не будет открыта форма
//                                с описанием изменений в новой версии программы. По умолчанию Истина.
//   МонопольныйРежим           - Булево - признак того, что обновление выполнилось в монопольном режиме.
//
// Пример:
//  Для обхода выполненных обработчиков обновления:
//  Для Каждого ИтерацияОбновления Из ИтерацииОбновления Цикл
//  	Для Каждого Версия Из ИтерацияОбновления.ВыполненныеОбработчики.Строки Цикл
//  		
//  		Если Версия.Версия = "*" Тогда
//  			// Группа обработчиков, которые выполняются регулярно при каждой смене версии.
//  		Иначе
//  			// Группа обработчиков, которые выполнились для определенной версии.
//  		КонецЕсли;
//  		
//  		Для Каждого Обработчик Из Версия.Строки Цикл
//  			...
//  		КонецЦикла;
//  		
//  	КонецЦикла;
//  КонецЦикла;
//
Процедура ПослеОбновленияИнформационнойБазы(Знач ПредыдущаяВерсияИБ, Знач ТекущаяВерсияИБ,
	Знач ИтерацииОбновления, ВыводитьОписаниеОбновлений, Знач МонопольныйРежим) Экспорт
	
	
КонецПроцедуры

// Вызывается при подготовке документа с описанием изменений в новой версии программы,
// которое выводится пользователю при первом входе в программу (после обновления).
//
// Параметры:
//   Макет - ТабличныйДокумент - описание изменений в новой версии программы, автоматически
//                               сформированное из общего макета ОписаниеИзмененийСистемы.
//                               Макет можно программно модифицировать или заменить на другой.
//
Процедура ПриПодготовкеМакетаОписанияОбновлений(Знач Макет) Экспорт
	
КонецПроцедуры

// Вызывается перед формирование списка отложенных обработчиков.
// Позволяет организовать дополнительные проверки списка отложенных обработчиков.
//
// Параметры:
//   ИтерацииОбновления     - Массив - массив структур, описывающих сведения об обновлении каждой
//                                     библиотеки и конфигурации, с ключами:
//       * Подсистема              - Строка - имя библиотеки или конфигурации.
//       * Версия                  - Строка - например, "2.1.3.39". Номер версии библиотеки (конфигурации).
//       * ЭтоОсновнаяКонфигурация - Булево - Истина, если это основная конфигурация, а не библиотека.
//       * Обработчики             - ТаблицаЗначений - все обработчики обновления библиотеки, описание колонок
//                                   см. в ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления.
//       * ВыполненныеОбработчики  - ДеревоЗначений - выполненные обработчики обновления, сгруппированные по
//                                   библиотеке и номеру версии, описание колонок
//                                   см. в ОбновлениеИнформационнойБазы.НоваяТаблицаОбработчиковОбновления.
//       * ИмяОсновногоСерверногоМодуля - Строка - имя модуля библиотеки (конфигурации), который предоставляет
//                                        основные сведения о ней: имя, версия и т.д.
//       * ОсновнойСерверныйМодуль      - ОбщийМодуль - общий модуль библиотеки (конфигурации), который предоставляет
//                                        основные сведения о ней: имя, версия и т.д.
//       * ПредыдущаяВерсия             - Строка - например, "2.1.3.30". Номер версии библиотеки (конфигурации) до обновления.
//
// Пример:
//  Обход всех обработчиков обновления:
//  Для Каждого ИтерацияОбновления Из ИтерацииОбновления Цикл
//		Если ИтерацияОбновления.Подсистема = "ИмяНашейПодсистемы" Тогда
//  		Для Каждого Обработчик Из ИтерацияОбновления.Обработчики Цикл
//  		
//  			Если Обработчик.Версия = "*" Тогда
//  				// Группа обработчиков, которые выполняются регулярно при каждой смене версии.
//  			Иначе
//  				// Группа обработчиков, которые выполняются для определенной версии.
//  			КонецЕсли;
//  		
//  		КонецЦикла;
//		КонецЕсли;
//  КонецЦикла;
//
Процедура ПередФормированиеСпискаОтложенныхОбработчиков(ИтерацииОбновления) Экспорт
	
КонецПроцедуры

// Необходимо для того, чтобы выгружать новые или измененные описания
// обработчиков обновления в код при помощи обработки ОписаниеОбработчиковОбновления
// только по тем подсистемам, разработка которых ведется в данной конфигурации.
// 
//
// Параметры:
//   РазрабатываемыеПодсистемы - Массив из Строка - имена разрабатываемых подсистемы в текущей конфигурации, 
//                                                  Имя подсистемы в том виде, в котором оно задано в общем модуле 
//                                                  ОбновлениеИнформационнойБазыХХХ.
//
Процедура ПриФормированииСпискаРазрабатываемыхПодсистем(РазрабатываемыеПодсистемы) Экспорт
	
	
	
КонецПроцедуры

// Вызывается после формирования порядка обновления типов метаданных (Константы, Справочники, Документы и т.д.).
// Используется для переопределения порядка обновления для какого-то конкретного объекта метаданных.  
//
// Параметры:
//   ПриоритетыТиповМетаданных - Соответствие из КлючИЗначение - порядок обновления типов метаданных:
//                   * Ключ - имя типа метаданного в единственном числе или полное имя конкретного типа метаданного
//                   * Значение - Число - порядок обновления
//
// Пример:
//  ПриоритетыТиповМетаданных.Вставить("РегистрСведений.РеестрДокументов", 120); 									
//
Процедура ПриЗаполненииПриоритетовТиповМетаданных(ПриоритетыТиповМетаданных) Экспорт
	
КонецПроцедуры

// Вызывается при выполнении функции ОбновлениеИнформационнойБазы.ОбъектОбработан.
// Позволяет написать произвольную логику для блокировки изменения объекта пользователем
// на время выполнения обновления программы.
//
// Параметры:
//  ПолноеИмяОбъекта - Строка - имя объекта, для которого вызывается проверка.
//  БлокироватьИзменение - Булево - если установить значение Истина, то объект
//                         будет открыт только для чтения. Значение по умолчанию - Ложь.
//  ТекстСообщения   - Строка - сообщение, которое будет выведено пользователю при открытии объекта.
//
Процедура ПриВыполненииПроверкиОбъектОбработан(ПолноеИмяОбъекта, БлокироватьИзменение, ТекстСообщения) Экспорт
	
КонецПроцедуры

// Определяет настройки начального заполнения элементов
// Позволяет задать общие настройки заполнение поставляемых данных для объектов, недоступных для изменения,
// стоящих на поддержке у другой библиотеки.
//
// Параметры:
//  ПолноеИмяОбъекта - Строка - имя объекта, для которого вызывается заполнение.
//  Настройки - Структура:
//   * ПриНачальномЗаполненииЭлемента - Булево - если Истина, то для каждого элемента будет
//      вызвана процедура индивидуального заполнения ПриНачальномЗаполненииЭлемента.
//   * ПредопределенныеДанные - ТаблицаЗначений - данные заполненные в процедуре ПриНачальномЗаполненииЭлементов.
//
Процедура ПриНастройкеНачальногоЗаполненияЭлементов(ПолноеИмяОбъекта, Настройки) Экспорт
	
КонецПроцедуры

// Вызывается при начальном заполнении объектов.
// Позволяет описать заполнение поставляемых данных для объектов, 
// недоступных для изменения, например стоящих на поддержке у другой библиотеки.
//
// Параметры:
//  ПолноеИмяОбъекта - Строка - имя объекта, для которого вызывается заполнение.
//  КодыЯзыков - Массив - список языков конфигурации. Актуально для мультиязычных конфигураций.
//  Элементы   - ТаблицаЗначений - данные заполнения. Состав колонок соответствует набору реквизитов объекта.
//  ТабличныеЧасти - Структура - описание табличных частей объекта, где:
//   * Ключ - Строка - имя табличной части;
//   * Значение - ТаблицаЗначений - табличная часть в виде таблицы значений, структуру которой
//                                  необходимо скопировать перед заполнением. Например:
//                                  Элемент.Ключи = ТабличныеЧасти.Ключи.Скопировать();
//                                  ЭлементТЧ = Элемент.Ключи.Добавить();
//                                  ЭлементТЧ.ИмяКлюча = "Первичный";
//
Процедура ПриНачальномЗаполненииЭлементов(ПолноеИмяОбъекта, КодыЯзыков, Элементы, ТабличныеЧасти) Экспорт
	
КонецПроцедуры

// Вызывается при начальном заполнении создаваемого объекта.
// Позволяет описать дополнительное заполнение или проверку поставляемого объекта,
// недоступного для изменения, например стоящего на поддержке у другой библиотеки.
//
// Параметры:
//  ПолноеИмяОбъекта - Строка - имя объекта, для которого вызывается заполнение.
//  Объект                  - заполняемый объект.
//  Данные                  - СтрокаТаблицыЗначений - данные заполнения объекта.
//  ДополнительныеПараметры - Структура:
//   * ПредопределенныеДанные - ТаблицаЗначений - данные заполненные в процедуре ПриНачальномЗаполненииЭлементов.
//
Процедура ПриНачальномЗаполненииЭлемента(ПолноеИмяОбъекта, Объект, Данные, ДополнительныеПараметры) Экспорт
	
КонецПроцедуры

// Вызывается при выполнении обработчика обновления,
// выполняющего очистку данных устаревших объектов метаданных.
//
// Кроме указанных устаревших объектов Удалить*, объекты метаданных,
// отключенные от подсистем библиотек, по-возможности добавляются
// ими автоматически в сокращение типов в измерениях своих регистров.
// Дополнительные сведения могут быть указаны в документации по внедрению
// подсистемы в подразделе "Удаление прикладных объектов из подсистемы".
//
// Параметры:
//  Объекты - см. ОбновлениеИнформационнойБазы.ДобавитьОбъектПланируемыйКУдалению.Объекты
//
// Пример:
//  ОбновлениеИнформационнойБазы.ДобавитьОбъектПланируемыйКУдалению(Объекты,
//		"Справочник.УдалитьОчередьЗаданий");
//	
//  ОбновлениеИнформационнойБазы.ДобавитьОбъектПланируемыйКУдалению(Объекты,
//		"Перечисление.УдалитьСовместимостьНоменклатуры");
//	
//  ОбновлениеИнформационнойБазы.ДобавитьОбъектПланируемыйКУдалению(Объекты,
//		"Перечисление.ХозяйственныеОперации.УдалитьСписаниеТоваровПереданныхПартнерам");
//	
//  ОбновлениеИнформационнойБазы.ДобавитьОбъектПланируемыйКУдалению(Объекты,
//		"БизнесПроцесс.Задание.ТочкаМаршрута.УдалитьВернутьИсполнителю");
//	
//  ОбновлениеИнформационнойБазы.ДобавитьОбъектПланируемыйКУдалению(Объекты,
//		"РегистрСведений.ВерсииОбъектов.Объект",
//		Новый ОписаниеТипов("СправочникСсылка.ФизическиеЛица,
//			|ДокументСсылка.НачислениеЗарплаты"));
//
Процедура ПриЗаполненииОбъектовПланируемыхКУдалению(Объекты) Экспорт
	
	
	
КонецПроцедуры

#Область УстаревшиеПроцедурыИФункции

// Устарела. Следует использовать 
// ОбновлениеИнформационнойБазыПереопределяемый.ПриФормированииСпискаРазрабатываемыхПодсистем
//
Процедура ПриФормированиеСпискаРазрабатываемыхПодсистем(РазрабатываемыеПодсистемы) Экспорт
	
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

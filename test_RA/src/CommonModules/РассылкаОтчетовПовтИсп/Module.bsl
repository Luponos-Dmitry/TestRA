///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Таблица типов получателей в разрезах хранения и пользовательского представления этих типов.
//
// Возвращаемое значение: 
//   ТаблицаЗначений - таблица типов получателей:
//       * ИдентификаторОбъектаМетаданных - СправочникСсылка.ИдентификаторыОбъектовМетаданных - ссылка, которая хранится
//                                                                                              в базе данных.
//       * ТипПолучателей  - ОписаниеТипов - тип, которым ограничиваются значения списков получателей и исключенных.
//       * Представление   - Строка - представление типа для пользователей.
//       * ОсновнойВидКИ   - СправочникСсылка.ВидыКонтактнойИнформации - вид контактной информации: e-mail, по
//                                                                       умолчанию.
//       * ГруппаКИ        - СправочникСсылка.ВидыКонтактнойИнформации - группа вида контактной информации.
//       * ПутьФормыВыбора - Строка - путь к форме выбора.
//
Функция ТаблицаТиповПолучателей() Экспорт
	
	ТаблицаТипов = Новый ТаблицаЗначений;
	ТаблицаТипов.Колонки.Добавить("ИдентификаторОбъектаМетаданных", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных"));
	ТаблицаТипов.Колонки.Добавить("ТипПолучателей", Новый ОписаниеТипов("ОписаниеТипов"));
	ТаблицаТипов.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	ТаблицаТипов.Колонки.Добавить("ОсновнойВидКИ", Новый ОписаниеТипов("СправочникСсылка.ВидыКонтактнойИнформации"));
	ТаблицаТипов.Колонки.Добавить("ГруппаКИ", Новый ОписаниеТипов("СправочникСсылка.ВидыКонтактнойИнформации"));
	ТаблицаТипов.Колонки.Добавить("ПутьФормыВыбора", Новый ОписаниеТипов("Строка"));
	ТаблицаТипов.Колонки.Добавить("ОсновнойТип", Новый ОписаниеТипов("ОписаниеТипов"));
	
	ТаблицаТипов.Индексы.Добавить("ИдентификаторОбъектаМетаданных");
	ТаблицаТипов.Индексы.Добавить("ТипПолучателей");
	
	ДоступныеТипы = Метаданные.Справочники.РассылкиОтчетов.ТабличныеЧасти.Получатели.Реквизиты.Получатель.Тип.Типы();
	
	// Параметры справочников "Пользователи" + "Группы пользователей".
	НастройкиТипа = Новый Структура;
	НастройкиТипа.Вставить("ОсновнойТип",       Тип("СправочникСсылка.Пользователи"));
	НастройкиТипа.Вставить("ДополнительныйТип", Тип("СправочникСсылка.ГруппыПользователей"));
	РассылкаОтчетов.ДобавитьЭлементВТаблицуТиповПолучателей(ТаблицаТипов, ДоступныеТипы, НастройкиТипа);
	
	// Механизм расширения
	РассылкаОтчетовПереопределяемый.ПереопределитьТаблицуТиповПолучателей(ТаблицаТипов, ДоступныеТипы);
	
	// Параметры остальных справочников.
	ПустойМассив = Новый Массив;
	Для Каждого НеиспользованныйТип Из ДоступныеТипы Цикл
		РассылкаОтчетов.ДобавитьЭлементВТаблицуТиповПолучателей(ТаблицаТипов, ПустойМассив, Новый Структура("ОсновнойТип", НеиспользованныйТип));
	КонецЦикла;
	
	Возврат ТаблицаТипов;
КонецФункции

// Исключаемые отчеты используются в качестве исключающего фильтра при выборе отчетов.
Функция ИсключаемыеОтчеты() Экспорт
	
	МассивМетаданных = Новый Массив;
	
	ИнтеграцияПодсистемБСП.ПриОпределенииИсключаемыхОтчетов(МассивМетаданных);
	РассылкаОтчетовПереопределяемый.ОпределитьИсключаемыеОтчеты(МассивМетаданных);
	
	Результат = Новый Массив;
	Для Каждого ОтчетМетаданные Из МассивМетаданных Цикл
		Результат.Добавить(ОбщегоНазначения.ИдентификаторОбъектаМетаданных(ОтчетМетаданные));
	КонецЦикла;
	
	ИсключаемыеОтчеты = Новый ФиксированныйМассив(Результат);
	
	Возврат ИсключаемыеОтчеты;
	
КонецФункции

Функция ПараметрыТекстаПисьмаИФайлов() Экспорт

	ПараметрыРассылки = Новый Структура;
	
	ПараметрыРассылки.Вставить("Получатель", НСтр("ru = 'Получатель'"));
	ПараметрыРассылки.Вставить("ДатаВыполнения", НСтр("ru = 'Дата выполнения'"));
	ПараметрыРассылки.Вставить("Автор", НСтр("ru = 'Автор'"));
	ПараметрыРассылки.Вставить("НаименованиеРассылки", НСтр("ru = 'Наименование рассылки'"));
	ПараметрыРассылки.Вставить("СформированныеОтчеты", НСтр("ru = 'Сформированные отчеты'"));
	ПараметрыРассылки.Вставить("ЗаголовокСистемы", НСтр("ru = 'Заголовок системы'"));
	ПараметрыРассылки.Вставить("СпособДоставки", НСтр("ru = 'Способ доставки'"));
	ПараметрыРассылки.Вставить("ФорматОтчета", НСтр("ru = 'Формат отчета'"));
	ПараметрыРассылки.Вставить("Период", НСтр("ru = 'Период'"));
	ПараметрыРассылки.Вставить("ДатаРассылки", НСтр("ru = 'Дата рассылки'"));
	ПараметрыРассылки.Вставить("НаименованиеОтчета", НСтр("ru = 'Наименование отчета'"));
	
	Возврат ПараметрыРассылки;

КонецФункции

#КонецОбласти

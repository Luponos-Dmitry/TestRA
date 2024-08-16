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
	
	Если ЗначениеЗаполнено(Объект.АвторФайлов) Тогда
		ВКачествеАвтораФайлов = "Пользователь";
		Элементы.АвторФайлов.Доступность = Истина;
	Иначе
		ВКачествеАвтораФайлов = "ПланОбмена";
		Элементы.АвторФайлов.Доступность = Ложь;
	КонецЕсли;
	
	АвтоНаименование = ПустаяСтрока(Объект.Наименование); 
	Если Не ПустаяСтрока(Объект.Наименование) Тогда
		Элементы.ВКачествеАвтораФайлов.СписокВыбора[0].Представление =
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Элементы.ВКачествеАвтораФайлов.Заголовок, "(" + Объект.Наименование + ")");
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЗапретРедактированияРеквизитовОбъектов") Тогда
		МодульЗапретРедактированияРеквизитовОбъектов = ОбщегоНазначения.ОбщийМодуль("ЗапретРедактированияРеквизитовОбъектов");
		МодульЗапретРедактированияРеквизитовОбъектов.ЗаблокироватьРеквизиты(ЭтотОбъект);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
		УстановитьПривилегированныйРежим(Истина);
		ПараметрыУчетнойЗаписи = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Объект.Ссылка, "Логин, Пароль");
		УстановитьПривилегированныйРежим(Ложь);
		
		Логин  = ПараметрыУчетнойЗаписи.Логин;
		Пароль = ?(ЗначениеЗаполнено(ПараметрыУчетнойЗаписи.Пароль), УникальныйИдентификатор, "");
		
	КонецЕсли;

	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.Наименование.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Верх;
	КонецЕсли
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(ТекущийОбъект.Ссылка, Логин, "Логин");
	Если ПарольИзменен Тогда
		ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(ТекущийОбъект.Ссылка, Пароль);
	КонецЕсли;
	УстановитьПривилегированныйРежим(Ложь);
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	АвтоНаименование = ПустаяСтрока(Объект.Наименование); 
КонецПроцедуры

&НаКлиенте
Процедура СервисОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не АвтоНаименование Тогда
		Возврат;
	КонецЕсли;

	ВыбранныйСервис = Элементы.Сервис.СписокВыбора.НайтиПоЗначению(ВыбранноеЗначение);
	Если Не ПустаяСтрока(ВыбранноеЗначение) И ВыбранныйСервис <> Неопределено Тогда
		Объект.Наименование = ВыбранныйСервис.Представление;	
	Иначе
		Объект.Наименование = НСтр("ru = 'Облачный сервис файлов'");	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВКачествеАвтораФайловПриИзменении(Элемент)
	
	Объект.АвторФайлов = Неопределено;
	Элементы.АвторФайлов.Доступность = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ПарольПриИзменении(Элемент)
	
	ПарольИзменен = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПроверитьНастройки(Команда)
	
	ОчиститьСообщения();
	
	Если Объект.Ссылка.Пустая() Или Модифицированность Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПроверитьНастройкиЗавершение", ЭтотОбъект);
		ТекстВопроса = НСтр("ru = 'Для проверки настроек необходимо записать данные учетной записи. Продолжить?'");
		Кнопки = Новый СписокЗначений;
		Кнопки.Добавить("Продолжить", НСтр("ru = 'Продолжить'"));
		Кнопки.Добавить(КодВозвратаДиалога.Отмена);
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, Кнопки);
		Возврат;
	КонецЕсли;
	
	ПроверитьВозможностьСинхронизацииСОблачнымСервисом();
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_РазрешитьРедактированиеРеквизитовОбъекта(Команда)
	
	МодульЗапретРедактированияРеквизитовОбъектовКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ЗапретРедактированияРеквизитовОбъектовКлиент");
	МодульЗапретРедактированияРеквизитовОбъектовКлиент.РазрешитьРедактированиеРеквизитовОбъекта(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПроверитьНастройкиЗавершение(РезультатДиалога, ДополнительныеПараметры) Экспорт
	
	Если РезультатДиалога <> "Продолжить" Тогда
		Возврат;
	КонецЕсли;
	
	Если Не Записать() Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьВозможностьСинхронизацииСОблачнымСервисом();
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьВозможностьСинхронизацииСОблачнымСервисом()
	
	СтруктураРезультата = ВыполнитьПроверкуПодключения(Объект.Ссылка);
	
	РезультатПротокол = СтруктураРезультата.РезультатПротокол;
	РезультатТекст = СтруктураРезультата.РезультатТекст;
	
	Если СтруктураРезультата.Отказ Тогда
		
		СообщениеОбОшибке = НСтр("ru = 'Проверка параметров для синхронизации файлов завершилась неудачно.
				|
				|Рекомендуем:
				|%3
				|
				|Технические подробности:
				|Сервис %1 вернул код ошибки %2.
				|%5%4'");
		Рекомендации = Новый Массив;
		Рекомендации.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Повторить попытку позднее (возможно временные неполадки на сервисе). Обратиться в поддержку сервиса %1.'"),
			Объект.Сервис));
		Рекомендации.Добавить(НСтр("ru='Выбрать другой сервис для синхронизации файлов.'"));
		
		ТекстОшибки = "";
		
		ТекстПротокола = СтроковыеФункцииКлиентСервер.ИзвлечьТекстИзHTML(РезультатПротокол);
		Если Не ЗначениеЗаполнено(СтруктураРезультата.КодОшибки) Тогда
			
			РезультатДиагностики = ПроверитьСоединение(Объект.Сервис, ТекстПротокола);
			ТекстОшибки          = РезультатДиагностики.ОписаниеОшибки;
			ТекстПротокола       = РезультатДиагностики.ЖурналДиагностики;
			
		ИначеЕсли СтруктураРезультата.КодОшибки = 404 Тогда
			Рекомендации.Вставить(0, НСтр("ru = 'Проверить, что указанная корневая папка существует в облачном сервисе.'"));
		ИначеЕсли СтруктураРезультата.КодОшибки = 401 Тогда
			Рекомендации.Вставить(0, НСтр("ru = 'Проверить правильность введенных логина и пароля.'"));
		ИначеЕсли СтруктураРезультата.КодОшибки = 10404 Тогда
			СтруктураРезультата.КодОшибки = СтруктураРезультата.КодОшибки - 10000;
			// Сервер, не поддерживает сохранение дополнительных свойств файлов
		ИначеЕсли СтруктураРезультата.КодОшибки = 501 Тогда
			// На сервере, не реализован один из методов протокола WebDAV
		Иначе
			Рекомендации.Вставить(0, НСтр("ru = 'Проверьте правильность введенных данных.'"));
		КонецЕсли;
		
		ПараметрыВопроса = СтандартныеПодсистемыКлиент.ПараметрыВопросаПользователю();
		ПараметрыВопроса.ПредлагатьБольшеНеЗадаватьЭтотВопрос = Ложь;
		ПараметрыВопроса.Картинка = БиблиотекаКартинок.ДиалогСтоп;
		ПараметрыВопроса.Заголовок = НСтр("ru = 'Проверка настройки'");
		
		ТекстРекомендаций = "";
		
		Для ИндексРекомендации = 0 По Рекомендации.ВГраница() Цикл
			ТекстРекомендаций = ТекстРекомендаций + СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("
			|    %1. %2", ИндексРекомендации+1, Рекомендации[ИндексРекомендации]);
		КонецЦикла;
			
		СтандартныеПодсистемыКлиент.ПоказатьВопросПользователю(
			Неопределено,
			 СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			СообщениеОбОшибке,
				Объект.Сервис, СтруктураРезультата.КодОшибки, ТекстРекомендаций, ТекстПротокола, 
				?(ЗначениеЗаполнено(ТекстОшибки),"", Символы.ПС+ТекстОшибки)),
			РежимДиалогаВопрос.ОК,
			ПараметрыВопроса);
		
	Иначе

		ПараметрыВопроса = СтандартныеПодсистемыКлиент.ПараметрыВопросаПользователю();
		ПараметрыВопроса.ПредлагатьБольшеНеЗадаватьЭтотВопрос = Ложь;
		ПараметрыВопроса.Картинка = БиблиотекаКартинок.Успешно32;
		ПараметрыВопроса.Заголовок = НСтр("ru = 'Проверка настройки'");
	
		СтандартныеПодсистемыКлиент.ПоказатьВопросПользователю(
			Неопределено,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Проверка параметров для синхронизации файлов завершилась успешно. 
						   |%1'"),
				РезультатТекст),
			РежимДиалогаВопрос.ОК,
			ПараметрыВопроса);
		
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Функция ВыполнитьПроверкуПодключения(Знач УчетнаяЗапись)
	СтруктураРезультата = Неопределено;
	РаботаСФайламиСлужебный.ВыполнитьПроверкуПодключения(УчетнаяЗапись, СтруктураРезультата);
	Возврат СтруктураРезультата; 
КонецФункции

&НаСервереБезКонтекста
Функция ПроверитьСоединение(Знач Сервис, Знач ТекстПротокола)
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
		Возврат МодульПолучениеФайловИзИнтернета.ДиагностикаСоединения(Сервис);
	Иначе
		
		Возврат Новый Структура("ОписаниеОшибки, ЖурналДиагностики",
			НСтр("ru = 'Проверьте соединение с сетью Интернет.'"), ТекстПротокола);
			
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ВКачествеАвтораФайловПользовательПриИзменении(Элемент)
	
	Элементы.АвторФайлов.Доступность = Истина;
	
КонецПроцедуры

#КонецОбласти
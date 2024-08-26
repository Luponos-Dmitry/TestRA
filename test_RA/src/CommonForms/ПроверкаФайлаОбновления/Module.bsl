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
	
	ИмяПервогоФайлаОбновления = Параметры.ИмяПервогоФайлаОбновления;
	МетаданныеВерсия = Метаданные.Версия;
	
	Если ОбновлениеИнформационнойБазыСлужебный.ОтложенноеОбновлениеЗавершено()
	 Или Не ЗначениеЗаполнено(ИмяПервогоФайлаОбновления)
	   И Не КонфигурацияИзменена() Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ЗначениеЗаполнено(ИмяПервогоФайлаОбновления) Тогда
		ЗагрузитьФайл();
		Если ТипЗнч(Результат) = Тип("Булево") Тогда
			Отказ = Истина;
		КонецЕсли;
	Иначе
	#Если Не ВебКлиент И Не МобильныйКлиент Тогда
		Попытка
			Результат = ИзменилсяТолькоНомерСборкиОсновнойКонфигурации();
		Исключение
			ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ЗаписатьОшибку(ТекстОшибки);
		КонецПопытки;
	#КонецЕсли
		Отказ = Истина;
		Если ТипЗнч(Результат) <> Тип("Булево") Тогда
			Результат = Ложь;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Если Не ВебКлиент И Не МобильныйКлиент Тогда

&НаКлиенте
Функция ИзменилсяТолькоНомерСборкиОсновнойКонфигурации()
	
	ПутьКВременнойПапке = ПолучитьИмяВременногоФайла() + "\";
	ИмяФайлаСписка    = ПутьКВременнойПапке + "ConfigFiles.txt";
	ИмяФайлаСообщений = ПутьКВременнойПапке + "Out.txt";
	
	СоздатьКаталог(ПутьКВременнойПапке);
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст("Configuration");
	ТекстовыйДокумент.Записать(ИмяФайлаСписка);
	
	ПараметрыСистемы = Новый Массив;
	ПараметрыСистемы.Добавить("DESIGNER");
	ПараметрыСистемы.Добавить("/DisableStartupMessages");
	ПараметрыСистемы.Добавить("/DisableStartupDialogs");
	ПараметрыСистемы.Добавить("/DumpConfigToFiles");
	ПараметрыСистемы.Добавить("""" + ПутьКВременнойПапке + """");
	ПараметрыСистемы.Добавить("-listfile");
	ПараметрыСистемы.Добавить("""" + ИмяФайлаСписка + """");
	ПараметрыСистемы.Добавить("/Out");
	ПараметрыСистемы.Добавить("""" + ИмяФайлаСообщений + """");
	
	КодВозврата = 0;
	ЗапуститьСистему(СтрСоединить(ПараметрыСистемы, " "), Истина, КодВозврата);
	
	Если КодВозврата <> 0 Тогда
		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.Прочитать(ИмяФайлаСообщений);
		УдалитьФайлы(ПутьКВременнойПапке);
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось выгрузить конфигурацию в файлы по причине:
			           |%1'"),
			"КодВозврата" + " = " + Строка(КодВозврата) + "
			|" + ТекстовыйДокумент.ПолучитьТекст());
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	ЧтениеXML = Новый ЧтениеXML;
	ПостроительDOM = Новый ПостроительDOM;
	ЧтениеXML.ОткрытьФайл(ПутьКВременнойПапке + "Configuration.xml");
	ДокументDOM = ПостроительDOM.Прочитать(ЧтениеXML);
	ЧтениеXML.Закрыть();
	
	УдалитьФайлы(ПутьКВременнойПапке);
	
	ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Не найдена версия в файле выгрузки %1'"),
		"Configuration.xml");
	
	Разыменователь = Новый РазыменовательПространствИменDOM(ДокументDOM);
	ВыражениеXPath = "/xmlns:MetaDataObject/xmlns:Configuration/xmlns:Properties/xmlns:Version";
	РезультатXPath = ДокументDOM.ВычислитьВыражениеXPath(ВыражениеXPath, ДокументDOM, Разыменователь);
	Если Не РезультатXPath.НеверноеСостояниеИтератора Тогда
		СледующийУзел = РезультатXPath.ПолучитьСледующий();
		Если ТипЗнч(СледующийУзел) = Тип("ЭлементDOM")
		   И ВРег(СледующийУзел.ИмяЭлемента) = ВРег("Version") Тогда
			Версия = СледующийУзел.ТекстовоеСодержимое;
			Если СтрРазделить(Версия, ".", Ложь).Количество() < 4 Тогда
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Некорректная версия ""%1"" в файле выгрузки %2'"),
					Версия, "Configuration.xml");
			Иначе
				Возврат ОбщегоНазначенияКлиентСервер.ВерсияКонфигурацииБезНомераСборки(МетаданныеВерсия)
				      = ОбщегоНазначенияКлиентСервер.ВерсияКонфигурацииБезНомераСборки(Версия);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	ВызватьИсключение ТекстОшибки;
	
КонецФункции

#КонецЕсли
&НаКлиенте
Процедура ЗагрузитьФайл()
	
	ПараметрыЗагрузки = ФайловаяСистемаКлиент.ПараметрыЗагрузкиФайла();
	ПараметрыЗагрузки.ИдентификаторФормы = УникальныйИдентификатор;
	ПараметрыЗагрузки.Интерактивно = Ложь;
	
	Оповещение = Новый ОписаниеОповещения("ПослеЗагрузкиФайла", ЭтотОбъект);
	ФайловаяСистемаКлиент.ЗагрузитьФайл(Оповещение, ПараметрыЗагрузки, ИмяПервогоФайлаОбновления);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗагрузкиФайла(ЗагруженныйФайл, Контекст) Экспорт
	
	Если ЗначениеЗаполнено(ЗагруженныйФайл)
	   И ЗначениеЗаполнено(ЗагруженныйФайл.Имя)
	   И ЗначениеЗаполнено(ЗагруженныйФайл.Хранение)
	   И ИзменилсяТолькоНомерСборки(ЗагруженныйФайл.Хранение, ЗагруженныйФайл.Имя) Тогда
		
		Результат = Истина;
	Иначе
		Результат = Ложь;
	КонецЕсли;
	
	Если Открыта() Тогда
		Закрыть(Результат);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ИзменилсяТолькоНомерСборки(АдресВоВременномХранилище, ПолноеИмяФайла)
	
	Попытка
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресВоВременномХранилище);
		УдалитьИзВременногоХранилища(АдресВоВременномХранилище);
		Если ТипЗнч(ДвоичныеДанные) <> Тип("ДвоичныеДанные") Тогда
			Возврат Ложь;
		КонецЕсли;
	
		Если СтрЗаканчиваетсяНа(ПолноеИмяФайла, ".cfu") Тогда
			ОписаниеОбновления = Новый ОписаниеОбновленияКонфигурации(ДвоичныеДанные);
			ОписаниеКонфигурации = ОписаниеОбновления.ПолучаемаяКонфигурация;
		Иначе
			ОписаниеКонфигурации = Новый ОписаниеКонфигурации(ДвоичныеДанные);
		КонецЕсли;
		ИзменилсяТолькоНомерСборки =
			  ОбщегоНазначенияКлиентСервер.ВерсияКонфигурацииБезНомераСборки(Метаданные.Версия)
			= ОбщегоНазначенияКлиентСервер.ВерсияКонфигурацииБезНомераСборки(ОписаниеКонфигурации.Версия);
	Исключение
		ТекстОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ЗаписатьОшибку(ТекстОшибки);
		ИзменилсяТолькоНомерСборки = Ложь;
	КонецПопытки;
	
	Возврат ИзменилсяТолькоНомерСборки;
	
КонецФункции

&НаСервереБезКонтекста
Процедура ЗаписатьОшибку(ТекстОшибки)
	
	ЗаголовокОшибки = НСтр("ru = 'Не удалось получить версию новой конфигурации по причине:'") + Символы.ПС;
	ЗаписьЖурналаРегистрации(ОбновлениеКонфигурации.СобытиеЖурналаРегистрации(),
		УровеньЖурналаРегистрации.Ошибка,,, ЗаголовокОшибки + ТекстОшибки);
	
КонецПроцедуры

#КонецОбласти

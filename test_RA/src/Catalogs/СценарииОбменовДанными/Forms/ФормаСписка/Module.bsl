///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВключитьОтключитьРегламентноеЗадание(Команда)
	
	ВыделенныеСтроки = Элементы.Список.ВыделенныеСтроки;
	
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	КоллекцияСценариев = Новый Массив;
	Для Каждого Сценарий Из ВыделенныеСтроки Цикл
		
		ДанныеСтроки = Элементы.Список.ДанныеСтроки(Сценарий);
		
		Если ДанныеСтроки.ПометкаУдаления Тогда
			Продолжить;
		КонецЕсли;
		
		КоллекцияСценариев.Добавить(Сценарий);
		
	КонецЦикла;
	
	ВключитьОтключитьРегламентноеЗаданиеНаСервере(КоллекцияСценариев, Не ТекущиеДанные.ИспользоватьРегламентноеЗадание);
	
	// Обновляем данные списка.
	Элементы.Список.Обновить();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Процедура ВключитьОтключитьРегламентноеЗаданиеНаСервере(КоллекцияСценариев, ИспользоватьРегламентноеЗадание)
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		Для Каждого Сценарий Из КоллекцияСценариев Цикл
			ЭлементБлокировки = Блокировка.Добавить("Справочник.СценарииОбменовДанными");
			ЭлементБлокировки.УстановитьЗначение("Ссылка", Сценарий);
		КонецЦикла;
		Блокировка.Заблокировать();
		
		Для Каждого Сценарий Из КоллекцияСценариев Цикл
			ЗаблокироватьДанныеДляРедактирования(Сценарий);
			СценарийОбъект = Сценарий.ПолучитьОбъект(); // СправочникОбъект.СценарииОбменовДанными
			СценарийОбъект.ИспользоватьРегламентноеЗадание = ИспользоватьРегламентноеЗадание;
			СценарийОбъект.Записать();
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

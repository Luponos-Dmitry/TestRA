///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Функция ОбъектЕстьВРегистре(Объект, УзелИнформационнойБазы) Экспорт
	
	ТекстЗапроса = "
	|ВЫБРАТЬ 1
	|ИЗ
	|	РегистрСведений.ДанныеОбъектовДляРегистрацииВОбменах КАК ДанныеОбъектовДляРегистрацииВОбменах
	|ГДЕ
	|	  ДанныеОбъектовДляРегистрацииВОбменах.УзелИнформационнойБазы           = &УзелИнформационнойБазы
	|	И ДанныеОбъектовДляРегистрацииВОбменах.Ссылка = &Объект
	|";
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("УзелИнформационнойБазы", УзелИнформационнойБазы);
	Запрос.УстановитьПараметр("Объект", Объект);
	Запрос.Текст = ТекстЗапроса;
	
	Возврат Не Запрос.Выполнить().Пустой();
КонецФункции

Процедура ДобавитьОбъектВФильтрРазрешенныхОбъектов(Знач Объект, Знач Получатель) Экспорт
	
	Если Не ОбъектЕстьВРегистре(Объект, Получатель) Тогда
		
		СтруктураЗаписи = Новый Структура;
		СтруктураЗаписи.Вставить("УзелИнформационнойБазы", Получатель);
		СтруктураЗаписи.Вставить("Ссылка", Объект);
		
		ДобавитьЗапись(СтруктураЗаписи, Истина);
	КонецЕсли;
	
КонецПроцедуры

Процедура УдалитьСведенияОВыгрузкеОбъектов(ВыгруженныеПоСсылкеОбъекты, УзелИнформационнойБазы) Экспорт
	
	СтруктураЗаписи = Новый Структура("Ссылка, УзелИнформационнойБазы");
	Если ТипЗнч(ВыгруженныеПоСсылкеОбъекты) = Тип("Массив") Тогда
		
		Для каждого ЭлементМассива Из ВыгруженныеПоСсылкеОбъекты Цикл
			
			СтруктураЗаписи.Ссылка = ЭлементМассива;
			СтруктураЗаписи.УзелИнформационнойБазы = УзелИнформационнойБазы;
			УдалитьЗапись(СтруктураЗаписи, Истина);
			
			
		КонецЦикла;
		
	Иначе
		
		СтруктураЗаписи.Ссылка = ВыгруженныеПоСсылкеОбъекты;
		СтруктураЗаписи.УзелИнформационнойБазы = УзелИнформационнойБазы;
		УдалитьЗапись(СтруктураЗаписи, Истина);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура добавляет запись в регистр по переданным значениям структуры.
Процедура ДобавитьЗапись(СтруктураЗаписи, Загрузка = Ложь)
	
	ОбменДаннымиСлужебный.ДобавитьЗаписьВРегистрСведений(СтруктураЗаписи, "ДанныеОбъектовДляРегистрацииВОбменах", Загрузка);
	
КонецПроцедуры

Процедура УдалитьЗапись(СтруктураЗаписи, Загрузка = Ложь)
	
	НачатьТранзакцию();
	Попытка
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ДанныеОбъектовДляРегистрацииВОбменах");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", СтруктураЗаписи.Ссылка);
		ЭлементБлокировки.УстановитьЗначение("УзелИнформационнойБазы", СтруктураЗаписи.УзелИнформационнойБазы);
		Блокировка.Заблокировать();
		
		// Используем набор, что бы поддержать ОбменДанными.Загрузка
		НаборЗаписей = РегистрыСведений.ДанныеОбъектовДляРегистрацииВОбменах.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Ссылка.Установить(СтруктураЗаписи.Ссылка, Истина);
		НаборЗаписей.Отбор.УзелИнформационнойБазы.Установить(СтруктураЗаписи.УзелИнформационнойБазы, Истина);
		НаборЗаписей.ОбменДанными.Загрузка = Загрузка;
		НаборЗаписей.Записать(Истина);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
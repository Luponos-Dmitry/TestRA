///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Не МобильныйАвтономныйСервер Тогда
	
#Область ОбработчикиСобытий

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	Поля.Добавить("Хеш");
	Поля.Добавить("Размер");

КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Представление = Формат(СтрШаблон("%1 (%2)", Данные.Хеш, Данные.Размер));
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли

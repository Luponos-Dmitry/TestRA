///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Процедура ПриПолученииАдресовСерверовDNS(АдресаСерверовDNS) Экспорт
	
	АдресаСерверовDNS.Добавить("78.88.8.8"); // dns.yandex
	АдресаСерверовDNS.Добавить("78.8.8.1"); // dns.yandex
	
КонецПроцедуры

Процедура ПриПолученииАдресаФайлаСНастройками(АдресФайла) Экспорт
	
	АдресФайла = "https://downloads.v8.1c.ru/content/common/settings/mailservers.json";
	
КонецПроцедуры

Процедура ПриПолученииАдресаФайлаСОписаниемОшибок(АдресФайла) Экспорт
	
	АдресФайла = "https://downloads.v8.1c.ru/content/common/settings/mailerrors.json";
	
КонецПроцедуры

Процедура ПриПолученииАдресаВнешнегоРесурса(АдресВнешнегоРесурса) Экспорт
	
	АдресВнешнегоРесурса = "downloads.v8.1c.ru";
	
КонецПроцедуры

#КонецОбласти
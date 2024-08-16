///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// См. СтандартныеПодсистемыСервер.НастройкиФорматовСохраненияТабличногоДокумента
//
Процедура ПриНастройкеФорматовСохраненияТабличногоДокумента(ТаблицаФорматов) Экспорт
	
	// Локализация
	// PDF (.pdf) (устаревший формат для ФНС)
	НовыйФормат = ТаблицаФорматов.Добавить();
	НовыйФормат.ТипФайлаТабличногоДокумента = ТипФайлаТабличногоДокумента.PDF;
	НовыйФормат.Ссылка = Перечисления.ФорматыСохраненияОтчетов.PDF;
	НовыйФормат.Расширение = "PDF";
	НовыйФормат.Картинка = БиблиотекаКартинок.ФорматPDF;
	НовыйФормат.Представление = НСтр("ru = 'Документ PDF (для ФНС)'");
	// Конец Локализация
	
КонецПроцедуры

#КонецОбласти
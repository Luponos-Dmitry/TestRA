///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Общие и персональные настройки работы с файлами.

// Возвращает структуру, содержащую ОбщиеНастройки и ПерсональныеНастройки.
Функция НастройкиРаботыСФайлами() Экспорт
	
	ОбщиеНастройки        = Новый Структура;
	ПерсональныеНастройки = Новый Структура;
	
	РаботаСФайламиСлужебный.ДобавитьНастройкиРаботыСФайлами(ОбщиеНастройки, ПерсональныеНастройки);
	
	ДобавитьНастройкиРаботыСФайлами(ОбщиеНастройки, ПерсональныеНастройки);
	
	Настройки = Новый Структура;
	Настройки.Вставить("ОбщиеНастройки",        ОбщиеНастройки);
	Настройки.Вставить("ПерсональныеНастройки", ПерсональныеНастройки);
	
	Возврат Настройки;
	
КонецФункции

// Устанавливает общие и персональные настройки файловых функций.
Процедура ДобавитьНастройкиРаботыСФайлами(ОбщиеНастройки, ПерсональныеНастройки)
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Заполнение общих настроек.
	
	ОбщиеНастройки.Вставить(
		"ИзвлекатьТекстыФайловНаСервере", РаботаСФайламиСлужебный.ИзвлекатьТекстыФайловНаСервере());
	ОбщиеНастройки.Вставить("МаксимальныйРазмерФайла", РаботаСФайлами.МаксимальныйРазмерФайла());
	
	ЗапрещатьЗагрузкуФайловПоРасширению = Константы.ЗапрещатьЗагрузкуФайловПоРасширению.Получить();
	Если ЗапрещатьЗагрузкуФайловПоРасширению = Неопределено Тогда
		ЗапрещатьЗагрузкуФайловПоРасширению = Ложь;
		Константы.ЗапрещатьЗагрузкуФайловПоРасширению.Установить(ЗапрещатьЗагрузкуФайловПоРасширению);
	КонецЕсли;
	ОбщиеНастройки.Вставить("ЗапретЗагрузкиФайловПоРасширению", ЗапрещатьЗагрузкуФайловПоРасширению);
	
	ОбщиеНастройки.Вставить("СписокЗапрещенныхРасширений", СписокЗапрещенныхРасширений());
	ОбщиеНастройки.Вставить("СписокРасширенийФайловOpenDocument", СписокРасширенийФайловOpenDocument());
	ОбщиеНастройки.Вставить("СписокРасширенийТекстовыхФайлов", СписокРасширенийТекстовыхФайлов());
	
	// Заполнение персональных настроек.
	
	МаксимальныйРазмерЛокальногоКэшаФайлов = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ЛокальныйКэшФайлов", "МаксимальныйРазмерЛокальногоКэшаФайлов");
	Если МаксимальныйРазмерЛокальногоКэшаФайлов = Неопределено Тогда
		МаксимальныйРазмерЛокальногоКэшаФайлов = 100*1024*1024; // 100 МБ.
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ЛокальныйКэшФайлов",
			"МаксимальныйРазмерЛокальногоКэшаФайлов", МаксимальныйРазмерЛокальногоКэшаФайлов);
	КонецЕсли;
	ПерсональныеНастройки.Вставить("МаксимальныйРазмерЛокальногоКэшаФайлов",
		МаксимальныйРазмерЛокальногоКэшаФайлов);
	
	ПутьКЛокальномуКэшуФайлов = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ЛокальныйКэшФайлов", "ПутьКЛокальномуКэшуФайлов");
	// Не следует получать эту переменную непосредственно.
	// Использовать функцию РаботаСФайламиСлужебныйКлиент.РабочийКаталогПользователя.
	ПерсональныеНастройки.Вставить("ПутьКЛокальномуКэшуФайлов", ПутьКЛокальномуКэшуФайлов);
	
	УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования =
		ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
			"ЛокальныйКэшФайлов", "УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования", Ложь);
	ПерсональныеНастройки.Вставить("УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования",
		УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования);
	
	ПоказыватьПодсказкиПриРедактированииФайлов = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиПрограммы", "ПоказыватьПодсказкиПриРедактированииФайлов");
	Если ПоказыватьПодсказкиПриРедактированииФайлов = Неопределено Тогда
		ПоказыватьПодсказкиПриРедактированииФайлов = Истина;
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("НастройкиПрограммы",
			"ПоказыватьПодсказкиПриРедактированииФайлов", ПоказыватьПодсказкиПриРедактированииФайлов);
	КонецЕсли;
	ПерсональныеНастройки.Вставить("ПоказыватьПодсказкиПриРедактированииФайлов",
		ПоказыватьПодсказкиПриРедактированииФайлов);
	
	ПоказыватьИнформациюЧтоФайлНеБылИзменен = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиПрограммы", "ПоказыватьИнформациюЧтоФайлНеБылИзменен");
	Если ПоказыватьИнформациюЧтоФайлНеБылИзменен = Неопределено Тогда
		ПоказыватьИнформациюЧтоФайлНеБылИзменен = Истина;
		
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(
			"НастройкиПрограммы",
			"ПоказыватьИнформациюЧтоФайлНеБылИзменен",
			ПоказыватьИнформациюЧтоФайлНеБылИзменен);
	КонецЕсли;
	ПерсональныеНастройки.Вставить("ПоказыватьИнформациюЧтоФайлНеБылИзменен",
		ПоказыватьИнформациюЧтоФайлНеБылИзменен);
	
	// Настройки открытия файлов.
	
	ТекстовыеФайлыРасширение = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ТекстовыеФайлы",
		"Расширение", "TXT XML INI");
	ТекстовыеФайлыСпособОткрытия = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ТекстовыеФайлы", 
		"СпособОткрытия",
		Перечисления.СпособыОткрытияФайлаНаПросмотр.ВоВстроенномРедакторе);
	ГрафическиеСхемыРасширение = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ГрафическиеСхемы", "Расширение", "GRS");
	ГрафическиеСхемыСпособОткрытия = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ГрафическиеСхемы",
		"СпособОткрытия", Перечисления.СпособыОткрытияФайлаНаПросмотр.ВоВстроенномРедакторе);
	
	ПерсональныеНастройки.Вставить("ТекстовыеФайлыРасширение",       ТекстовыеФайлыРасширение);
	ПерсональныеНастройки.Вставить("ТекстовыеФайлыСпособОткрытия",   ТекстовыеФайлыСпособОткрытия);
	ПерсональныеНастройки.Вставить("ГрафическиеСхемыРасширение",     ГрафическиеСхемыРасширение);
	ПерсональныеНастройки.Вставить("ГрафическиеСхемыСпособОткрытия", ГрафическиеСхемыСпособОткрытия);
	
КонецПроцедуры

Функция СписокЗапрещенныхРасширений()
	
	УстановитьПривилегированныйРежим(Истина);
	
	СписокРасширений = Константы.СписокЗапрещенныхРасширенийОбластиДанных.Получить();
	Если СписокРасширений = Неопределено ИЛИ СписокРасширений = "" Тогда
		СписокРасширений = ВРег(СтрСоединить(РаботаСФайламиСлужебный.СписокЗапрещенныхРасширений().ВыгрузитьЗначения(), " "));
		Константы.СписокЗапрещенныхРасширенийОбластиДанных.Установить(СписокРасширений);
	КонецЕсли;
	
	Результат = "";
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		СписокЗапрещенныхРасширений = Константы.СписокЗапрещенныхРасширений.Получить();
		Результат = СписокЗапрещенныхРасширений + " "  + СписокРасширений;
	Иначе
		Результат = СписокРасширений;
	КонецЕсли;
		
	Возврат Результат;
	
КонецФункции

Функция СписокРасширенийФайловOpenDocument()
	
	УстановитьПривилегированныйРежим(Истина);
	
	СписокРасширенийФайловOpenDocumentОбластиДанных =
		Константы.СписокРасширенийФайловOpenDocumentОбластиДанных.Получить();
	
	Если СписокРасширенийФайловOpenDocumentОбластиДанных = Неопределено
	 ИЛИ СписокРасширенийФайловOpenDocumentОбластиДанных = "" Тогда
		
		СписокРасширенийФайловOpenDocumentОбластиДанных =
			"ODT OTT ODP OTP ODS OTS ODC OTC ODF OTF ODM OTH SDW STW SXW STC SXC SDC SDD STI";
		
		Константы.СписокРасширенийФайловOpenDocumentОбластиДанных.Установить(
			СписокРасширенийФайловOpenDocumentОбластиДанных);
	КонецЕсли;
	
	ИтоговыйСписокРасширений = "";
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		СписокЗапрещенныхРасширений = Константы.СписокРасширенийФайловOpenDocument.Получить();
		
		ИтоговыйСписокРасширений =
			СписокЗапрещенныхРасширений + " "  + СписокРасширенийФайловOpenDocumentОбластиДанных;
	Иначе
		ИтоговыйСписокРасширений = СписокРасширенийФайловOpenDocumentОбластиДанных;
	КонецЕсли;
	
	Возврат ИтоговыйСписокРасширений;
	
КонецФункции

Функция СписокРасширенийТекстовыхФайлов()

	УстановитьПривилегированныйРежим(Истина);
	СписокРасширенийТекстовыхФайлов = Константы.СписокРасширенийТекстовыхФайлов.Получить();
	УстановитьПривилегированныйРежим(Ложь);
	Если ПустаяСтрока(СписокРасширенийТекстовыхФайлов) Тогда
		СписокРасширенийТекстовыхФайлов = РаботаСФайламиСлужебный.СписокРасширенийТекстовыхФайлов();
	КонецЕсли;
	Возврат СписокРасширенийТекстовыхФайлов;

КонецФункции

// Возвращает признак принадлежности узла к плану обмена РИБ.
//
// Параметры:
//  ПолноеИмяПланаОбмена - Строка - плана обмена, для которого требуется получить значение функции.
//
//  Возвращаемое значение:
//    Булево - Истина - узел принадлежит плану обмена РИБ, иначе Ложь.
//
Функция ЭтоУзелРаспределеннойИнформационнойБазы(ПолноеИмяПланаОбмена) Экспорт

	Возврат ОбщегоНазначения.ОбъектМетаданныхПоПолномуИмени(ПолноеИмяПланаОбмена).РаспределеннаяИнформационнаяБаза;
	
КонецФункции

// Для функции см. ПолныйПутьТома.
// 
// Возвращаемое значение:
//  Булево
//
Функция ПутьКТомуБезУчетаРегиональныхНастроек() Экспорт
	Возврат Константы.ПутьКТомуБезУчетаРегиональныхНастроек.Получить();
КонецФункции

// Возвращает признак того, что данные перенесены в новый регистр.
//
//  Возвращаемое значение:
//    Булево - Истина - данные перенесены, иначе Ложь.
// 
Функция ДедупликацияВыполнена() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК Проверка
	|ИЗ
	|	РегистрСведений.УдалитьДвоичныеДанныеФайлов КАК УдалитьДвоичныеДанныеФайлов";
	
	Возврат Запрос.Выполнить().Пустой();
	
КонецФункции

#КонецОбласти

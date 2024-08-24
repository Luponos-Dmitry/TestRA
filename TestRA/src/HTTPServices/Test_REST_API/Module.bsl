
Функция aboutme(Запрос)

	Ответ = Новый HTTPСервисОтвет(200);
	ТекстОтвета = "TestRA: Тестовый API для обучения разработчиков методам работы с HTTP сервисами обмена";
	Для Каждого ПараметрАдреса Из Запрос.ПараметрыURL Цикл
		ТекстОтвета = ТекстОтвета + СтрШаблон("ПараметрыURL. ключ: %1, значение: %2", ПараметрАдреса.Ключ, ПараметрАдреса.Значение) + Символы.ПС;
	КонецЦикла;
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "text/plain; charset=utf-8");
	Ответ.Заголовки = Заголовки;
	ОтветСодержимое = Новый Структура; 
	ОтветСодержимое.Вставить("text", ТекстОтвета);
	ДанныеТела = Base64Строка(БиблиотекаКартинок.КартинкаRestAPI.ПолучитьДвоичныеДанные());
	ОтветСодержимое.Вставить("picture", ДанныеТела);
	ОтветJSON = Новый ЗаписьJSON; 
	ОтветJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(,Символы.Таб));
	ЗаписатьJSON(ОтветJSON,ОтветСодержимое); 
	СтрокаJSON = ОтветJSON.Закрыть(); 
	Ответ.УстановитьТелоИзСтроки(СтрокаJSON);
	Возврат Ответ; 
	
КонецФункции

                                                                   
Функция abouto(Запрос)

	Ответ = Новый HTTPСервисОтвет(200);
	ТекстОтвета = "TestRA: Тестовый API для обучения разработчиков методам работы с HTTP сервисами обмена";
	Для Каждого ПараметрАдреса Из Запрос.ПараметрыURL Цикл
		ТекстОтвета = ТекстОтвета + СтрШаблон("ПараметрыURL. ключ: %1, значение: %2", ПараметрАдреса.Ключ, ПараметрАдреса.Значение) + Символы.ПС;
	КонецЦикла;
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "text/plain; charset=utf-8");
	Ответ.Заголовки = Заголовки;
	ОтветСодержимое = Новый Структура; 
	ОтветСодержимое.Вставить("text", ТекстОтвета);
	ДанныеТела = Base64Строка(БиблиотекаКартинок.КартинкаRestAPI.ПолучитьДвоичныеДанные());
	ОтветСодержимое.Вставить("picture", ДанныеТела);
	ОтветJSON = Новый ЗаписьJSON; 
	ОтветJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(,Символы.Таб));
	ЗаписатьJSON(ОтветJSON,ОтветСодержимое); 
	СтрокаJSON = ОтветJSON.Закрыть(); 
	Ответ.УстановитьТелоИзСтроки(СтрокаJSON);
	Возврат Ответ;
	
КонецФункции


Функция IPRFsendfile(Запрос)

	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки(TestRAМодули.ВыгрузитьДаныеРегистра_ipRFДляRouterOS(),КодировкаТекста.UTF8); 
	Возврат Ответ;

	Возврат TestRAМодули.ВыгрузитьДаныеРегистра_ipRF(); 
КонецФункции

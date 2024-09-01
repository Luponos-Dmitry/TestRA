Функция ВыгрузитьДаныеРегистра_ipRFДляRouterOS() Экспорт
	
	СтрокаВозврата = "/ip firewall address-list" + Символы.ПС; 
	Запрос = Новый Запрос; 
	Запрос.Текст = "ВЫБРАТЬ
	               |	IpRF.ip КАК ip
	               |ИЗ
	               |	РегистрСведений.IpRF КАК IpRF"; 
	Выборка = Запрос.Выполнить().Выбрать(); 
	Пока Выборка.Следующий() Цикл 
		СтрокаВозврата = СтрокаВозврата + "add address=" + Выборка.ip + " comment="""" list=ipRF" + Символы.ПС; 
	КонецЦикла; 
	Возврат СтрокаВозврата; 
	
КонецФункции

Функция aboutme(Запрос) Экспорт

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
	ПользовательСтруктура  = Новый Структура("Ссылка, Наименование"); 
	ЗаполнитьЗначенияСвойств(ПользовательСтруктура, Пользователи.АвторизованныйПользователь()); 
	ОтветСодержимое.Вставить("token", XMLСтрока(ПользовательСтруктура.Ссылка));
	ОтветСодержимое.Вставить("name", ПользовательСтруктура.Наименование);
	ОтветСодержимое.Вставить("externalUser", Строка(Пользователи.ЭтоСеансВнешнегоПользователя()));
	ОтветJSON = Новый ЗаписьJSON; 
	ОтветJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(,Символы.Таб));
	ЗаписатьJSON(ОтветJSON,ОтветСодержимое); 
	СтрокаJSON = ОтветJSON.Закрыть(); 
	Ответ.УстановитьТелоИзСтроки(СтрокаJSON);
	Возврат Ответ; 
	
КонецФункции

Функция PipeMessFile(ВходящийЗапрос) Экспорт

	Ответ = Новый HTTPСервисОтвет(200);
	Пользователь = Пользователи.АвторизованныйПользователь();
	Запрос = Новый Запрос; 
	Запрос.Текст = "ВЫБРАТЬ
	               |	RAСообщения.Ссылка КАК Ссылка,
	               |	RAСообщения.Пользователь КАК Пользователь,
	               |	RAСообщения.GuidСообщения КАК GuidСообщения,
	               |	RAСообщения.ТекстСообщения КАК ТекстСообщения
	               |ИЗ
	               |	РегистрСведений.RAСообщения КАК RAСообщения
	               |ГДЕ
	               |	RAСообщения.Пользователь = &Пользователь
	               |	И НЕ RAСообщения.ОбменПринят"; 
	Запрос.УстановитьПараметр("Пользователь", Пользователь); 
	Результат = Запрос.Выполнить().Выбрать();
	ОтветСодержимое = Новый Массив; 
	Пока Результат.Следующий() Цикл  
		ОтветСодержимое.Добавить(Новый Структура("user,guid,message",XMLСтрока(Результат.Пользователь),Результат.GuidСообщения,Результат.ТекстСообщения));	
	КонецЦикла;
	// +++ Лупонос Д.В. 2024-08-27 Добавлены идентификационные данные пользователя системы для отладки 
	ПользовательСтруктура  = Новый Структура("Ссылка, Наименование"); 
	ЗаполнитьЗначенияСвойств(ПользовательСтруктура, Пользователи.АвторизованныйПользователь()); 
	ЭтоВнешнийПользователь = Пользователи.ЭтоСеансВнешнегоПользователя();
	GUIDПользователя = XMLСтрока(ПользовательСтруктура.Ссылка); 
	ОтветСодержимое.Добавить(Новый Структура("authuser,externalUser,name",GUIDПользователя,XMLСтрока(ЭтоВнешнийПользователь),ПользовательСтруктура.Наименование));
	// --- Лупонос Д.В. 2024-08-27 Добавлены идентификационные данные пользователя системы для отладки 
	ОтветJSON = Новый ЗаписьJSON; 
	//ОтветJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON(,Символы.Таб));
	ОтветJSON.УстановитьСтроку(); 
	ЗаписатьJSON(ОтветJSON,ОтветСодержимое[0]); 
	СтрокаJSON = ОтветJSON.Закрыть(); 
	Ответ.УстановитьТелоИзСтроки(СтрокаJSON);
	Возврат Ответ;
	
КонецФункции
